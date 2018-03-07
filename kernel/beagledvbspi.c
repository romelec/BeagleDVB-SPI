/*
 * Kernel module for BeagleDVB-SPI Interface for the BeagleBone [Black]
 * Designed to be used in conjunction with a modified pru_rproc driver
 *
 * Copyright (C) 2014-17 Kumar Abhishek <abhishek@theembeddedkitchen.net>
 * Copyright (C) 2017 R Colomban
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.
 */

#include <asm/atomic.h>
#include <asm/uaccess.h>

#include <linux/module.h>
#include <linux/err.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/wait.h>
#include <linux/poll.h>

#include <linux/platform_device.h>
#include <linux/pruss.h>
#include <linux/remoteproc.h>
#include <linux/miscdevice.h>

#include <linux/io.h>
#include <linux/interrupt.h>
#include <linux/irqreturn.h>
#include <linux/slab.h>
#include <linux/genalloc.h>
#include <linux/mm.h>
#include <linux/dma-mapping.h>

#include <linux/kobject.h>
#include <linux/string.h>

#include <linux/of.h>
#include <linux/of_platform.h>
#include <linux/of_address.h>
#include <linux/of_device.h>

#include <linux/sysfs.h>
#include <linux/fs.h>

#include "beagledvbspi.h"

/* Buffer states */
enum bufstates {
	STATE_BL_BUF_ALLOC,
	STATE_BL_BUF_MAPPED,
	STATE_BL_BUF_UNMAPPED,
	STATE_BL_BUF_DROPPED
};

/* PRU Commands */
#define CMD_GET_VERSION 1   /* Firmware version */
#define CMD_GET_MAX_SG  2   /* Get the max number of bufferlist entries */
#define CMD_SET_CONFIG  3   /* Get the context pointer */
#define CMD_START       4   /* Arm the LA (start sampling) */

/* PRU-side sample buffer descriptor */
struct buflist {
	uint32_t dma_start_addr;
	uint32_t dma_end_addr;
};

/* Shared structure containing PRU attributes */
struct capture_context {
	/* Magic bytes */
#define BL_FW_MAGIC	0xBEA61E10
	uint32_t magic;         // Magic bytes, should be 0xBEA61E10

	uint32_t cmd;           // Command from Linux host to us
	uint32_t resp;          // Response code

	uint32_t samplediv;     // Sample rate = (100 / samplediv) MHz // unused
	uint32_t sampleunit;    // 0 = 16-bit, 1 = 8-bit // unused
	uint32_t triggerflags;  // 0 = one-shot, 1 = continuous sampling

	struct buflist list_head;
};

/* Forward declration */
static const struct file_operations pru_beagledvbspi_fops;

/* Buffers are arranged as an array but are
 * also circularly linked to simplify reads */
struct logic_buffer {
	void *buf;
	dma_addr_t phys_addr;
	size_t size;

	unsigned short state;
	unsigned short index;

	struct logic_buffer *next;
};

struct beagledvbspi_private_data {
	const char *fw_names[PRUSS_NUM_PRUS];
};

struct beagledvbspidev {
	/* Misc device descriptor */
	struct miscdevice miscdev;

	/* Handle to pruss structure and PRU0 SRAM */
	struct pruss *pruss;
	struct rproc *pru0, *pru1;
	struct pruss_mem_region pru0sram;
	const struct beagledvbspi_private_data *fw_data;

	/* IRQ numbers */
	int to_bl_irq;
	int from_bl_irq_1;
	int from_bl_irq_2;

	/* Core clock frequency: Required for configuring sample rates */
	uint32_t coreclockfreq;

	/* Private data */
	struct device *p_dev; /* Parent platform device */

	/* Locks */
	struct mutex mutex;

	/* Buffer management */
	struct logic_buffer *buffers;
	struct logic_buffer *lastbufready;
	struct logic_buffer *bufbeingread;
	uint32_t bufcount;
	wait_queue_head_t wait;

	/* ISR Bookkeeping */
	uint32_t previntcount;	/* Previous interrupt count read from PRU */

	/* Firmware capabilities */
	struct capture_context *cxt_pru;

	/* Device capabilities */
	uint32_t maxbufcount;	/* Max buffer count supported by the PRU FW */
	uint32_t bufunitsize;  	/* Size of 1 Allocation unit */
    uint32_t triggerflags;  // 0 = one-shot, 1 = continuous sampling

	/* State */
	uint32_t state;
	uint32_t lasterror;
};

struct logic_buffer_reader {
	struct beagledvbspidev *bldev;
	struct logic_buffer *buf;

	uint32_t pos;
	uint32_t remaining;
};

#define to_beagledvbspidev(dev)	container_of((dev), \
		struct beagledvbspidev, miscdev)

#define DRV_NAME	"beagledvbspi"
#define DRV_VERSION	"1.0"

/* Begin Buffer Management section */

/* Allocate DMA buffers for the PRU
 * This method acquires & releases the device mutex */
static int beagledvbspi_memalloc(struct device *dev, uint32_t bufsize)
{
	struct beagledvbspidev *bldev = dev_get_drvdata(dev);
	int i, cnt;
	void *buf;

	/* Check if BL is in use */
	if (!mutex_trylock(&bldev->mutex))
		return -EBUSY;

	/* Compute no. of buffers to allocate, round up
	 * We need at least two buffers for ping-pong action */
	cnt = max(DIV_ROUND_UP(bufsize, bldev->bufunitsize), (uint32_t)2);

	/* Too large? */
	if (cnt > bldev->maxbufcount) {
		dev_err(dev, "Not enough memory\n");
		return -ENOMEM;
	}

	bldev->bufcount = cnt;

	/* Allocate buffer list */
	bldev->buffers = devm_kzalloc(dev, sizeof(struct logic_buffer) * (cnt),
			GFP_KERNEL);
	if (!bldev->buffers)
		goto failnomem;

	/* Allocate DMA buffers */
	for (i = 0; i < cnt; i++) {
		buf = kmalloc(bldev->bufunitsize, GFP_KERNEL);
		if (!buf)
			goto failrelease;

		/* Fill with 0xFF */
		memset(buf, 0xFF, bldev->bufunitsize);

		/* Set the buffers */
		bldev->buffers[i].buf = buf;
		bldev->buffers[i].phys_addr = virt_to_phys(buf);
		bldev->buffers[i].size = bldev->bufunitsize;
		bldev->buffers[i].index = i;

		/* Circularly link the buffers */
		bldev->buffers[i].next = &bldev->buffers[(i + 1) % cnt];
	}

	/* Write log and unlock */
	dev_info(dev, "Successfully allocated %d bytes of memory.\n",
			cnt * bldev->bufunitsize);

	mutex_unlock(&bldev->mutex);

	/* Done */
	return 0;
failrelease:
	for (i = 0; i < cnt; i++) {
		if (bldev->buffers[i].buf)
			kfree(bldev->buffers[i].buf);
	}
	devm_kfree(dev, bldev->buffers);
	bldev->bufcount = 0;
	bldev->buffers = NULL;
	dev_err(dev, "Sample buffer allocation:");
failnomem:
	dev_err(dev, "Not enough memory\n");
	mutex_unlock(&bldev->mutex);
	return -ENOMEM;
}

/* Frees the DMA buffers and the bufferlist */
static void beagledvbspi_memfree(struct device *dev)
{
	struct beagledvbspidev *bldev = dev_get_drvdata(dev);
	int i;

	mutex_lock(&bldev->mutex);
	if (bldev->buffers) {
		for (i = 0; i < bldev->bufcount; i++)
			if (bldev->buffers[i].buf)
				kfree(bldev->buffers[i].buf);

		devm_kfree(dev, bldev->buffers);
		bldev->buffers = NULL;
		bldev->bufcount = 0;
	}
	mutex_unlock(&bldev->mutex);
}

/* No argument checking for the map/unmap functions */
static int beagledvbspi_map_buffer(struct device *dev, struct logic_buffer *buf)
{
	dma_addr_t dma_addr;

	/* If already mapped, do nothing */
	if (buf->state == STATE_BL_BUF_MAPPED)
		return 0;

	dma_addr = dma_map_single(dev, buf->buf, buf->size, DMA_FROM_DEVICE);
	if (dma_mapping_error(dev, dma_addr))
		goto fail;
	else {
		buf->phys_addr = dma_addr;
		buf->state = STATE_BL_BUF_MAPPED;
	}

	return 0;
fail:
	dev_err(dev, "DMA Mapping error. \n");
	return -1;
}

static void beagledvbspi_unmap_buffer(struct device *dev,
                                     struct logic_buffer *buf)
{
	dma_unmap_single(dev, buf->phys_addr, buf->size, DMA_FROM_DEVICE);
	buf->state = STATE_BL_BUF_UNMAPPED;
}

/* Fill the sample buffer with a pattern of increasing 32-bit ints
 * This can be studied to watch out for dropped bytes/buffers */
static void beagledvbspi_fill_buffer_testpattern(struct device *dev)
{
	struct beagledvbspidev *bldev = dev_get_drvdata(dev);
	int i, j;
	uint32_t cnt = 0, *addr;

	mutex_lock(&bldev->mutex);
	for (i = 0; i < bldev->bufcount; i++) {
		addr = bldev->buffers[i].buf;

		for (j = 0; j < bldev->buffers[i].size / sizeof(cnt); j++)
			*addr++ = cnt++;
	}
	mutex_unlock(&bldev->mutex);
}

/* Map all the buffers. This is done just before beginning a sample operation
 * NOTE: PRUs are halted at this time */
static int beagledvbspi_map_and_submit_all_buffers(struct device *dev)
{
	struct beagledvbspidev *bldev = dev_get_drvdata(dev);
	struct buflist *pru_buflist = &bldev->cxt_pru->list_head;
	int i, j;
	dma_addr_t addr;

	if (!pru_buflist)
		return -1;

	for (i = 0; i < bldev->bufcount;i++) {
		if (beagledvbspi_map_buffer(dev, &bldev->buffers[i]))
			goto fail;
	}

	/* Write buffer table to the PRU memory, and null terminate */
	for (i = 0; i < bldev->bufcount; i++) {
		addr = bldev->buffers[i].phys_addr;
		pru_buflist[i].dma_start_addr = addr;
		pru_buflist[i].dma_end_addr = addr + bldev->buffers[i].size;
	}
	pru_buflist[i].dma_start_addr = 0;
	pru_buflist[i].dma_end_addr = 0;

	/* Update state to ready */
	if (i)
		bldev->state = STATE_BL_ARMED;

	return 0;
fail:
	/* Unmap the buffers */
	for (j = 0; j < i; j++)
		beagledvbspi_unmap_buffer(dev, &bldev->buffers[i]);

	dev_err(dev, "DMA Mapping failed at i=%d\n", i);

	bldev->state = STATE_BL_ERROR;
	return 1;
}

/* End Buffer Management section */

/* Send command to the PRU firmware */
static int beagledvbspi_send_cmd(struct beagledvbspidev *bldev, uint32_t cmd)
{
#define TIMEOUT     200
	uint32_t timeout = TIMEOUT;

	bldev->cxt_pru->cmd = cmd;

	/* Wait for firmware to process the command */
	while (--timeout && bldev->cxt_pru->cmd != 0)
		cpu_relax();

	if (timeout == 0)
		return -1;

	return bldev->cxt_pru->resp;
}

/* Request the PRU firmware to stop capturing */
static void beagledvbspi_request_stop(struct beagledvbspidev *bldev)
{
	/* Trigger interrupt */
	pruss_intc_trigger(bldev->to_bl_irq);
}

/* This is [to be] called from a threaded IRQ handler */
irqreturn_t beagledvbspi_serve_irq(int irqno, void *data)
{
	struct beagledvbspidev *bldev = data;
	struct device *dev = bldev->miscdev.this_device;
	uint32_t state = bldev->state;

	dev_dbg(dev, "Beagledvbspi IRQ #%d\n", irqno);
	if (irqno == bldev->from_bl_irq_1) {
		/* Manage the buffers */
		bldev->lastbufready = bldev->bufbeingread;
		beagledvbspi_unmap_buffer(dev, bldev->lastbufready);

		/* Avoid a false buffer overrun warning on the last run */
		if (bldev->bufbeingread->next->index != 0) {
			bldev->bufbeingread = bldev->bufbeingread->next;
			beagledvbspi_map_buffer(dev, bldev->bufbeingread);
		}
		wake_up_interruptible(&bldev->wait);
	} else if (irqno == bldev->from_bl_irq_2) {
		/* This interrupt occurs twice:
		 *  1. After a successful configuration of PRU capture
		 *  2. After the last buffer transferred  */
		state = bldev->state;
		if (state <= STATE_BL_ARMED) {
			dev_dbg(dev, "config written, Beagledvbspi ready\n");
			return IRQ_HANDLED;
		}
		else if (state != STATE_BL_REQUEST_STOP &&
				state != STATE_BL_RUNNING) {
			dev_err(dev, "Unexpected stop request \n");
			bldev->state = STATE_BL_ERROR;
			return IRQ_HANDLED;
		}
		bldev->state = STATE_BL_INITIALIZED;
		wake_up_interruptible(&bldev->wait);
	}

	return IRQ_HANDLED;
}

/* Write configuration into the PRU [via downcall] (assume mutex is held) */
int beagledvbspi_write_configuration(struct device *dev)
{
	struct beagledvbspidev *bldev = dev_get_drvdata(dev);
	int ret;

    /* Hand over the settings */
	bldev->cxt_pru->triggerflags = bldev->triggerflags;
	/* No settings to send */
	ret = beagledvbspi_send_cmd(bldev, CMD_SET_CONFIG);

	dev_dbg(dev, "PRU Config written, err code = %d\n", ret);
	return 0;
}

/* Begin the sampling operation [This takes the mutex] */
int beagledvbspi_start(struct device *dev)
{
	struct beagledvbspidev *bldev = dev_get_drvdata(dev);

	/* This mutex will be locked for the entire duration Beagledvbspi runs */
	mutex_lock(&bldev->mutex);
	if (beagledvbspi_write_configuration(dev)) {
		mutex_unlock(&bldev->mutex);
		return -1;
	}
	bldev->bufbeingread = &bldev->buffers[0];
	beagledvbspi_send_cmd(bldev, CMD_START);

	/* All set now. Start the PRUs and wait for IRQs */
	bldev->state = STATE_BL_RUNNING;
	bldev->lasterror = 0;

	dev_info(dev, "capture started\n");
	return 0;
}

/* Request stop. Stop will effect only after the last buffer is written out */
void beagledvbspi_stop(struct device *dev)
{
	struct beagledvbspidev *bldev = dev_get_drvdata(dev);

	if (mutex_is_locked(&bldev->mutex)) {
		if (bldev->state == STATE_BL_RUNNING)
		{
			beagledvbspi_request_stop(bldev);
			bldev->state = STATE_BL_REQUEST_STOP;

			/* Wait for the PRU to signal completion */
			wait_event_interruptible(bldev->wait,
					bldev->state == STATE_BL_INITIALIZED);
		}
		/* Release */
		mutex_unlock(&bldev->mutex);

		dev_info(dev, "capture session ended\n");
	}
}

/* fops */
static int beagledvbspi_f_open(struct inode *inode, struct file *filp)
{
	struct logic_buffer_reader *reader;
	struct beagledvbspidev *bldev = to_beagledvbspidev(filp->private_data);
	struct device *dev = bldev->miscdev.this_device;

	if (bldev->bufcount == 0)
    {
        dev_err(dev, "no buffer\n");
        return -ENOMEM;
    }

	reader = devm_kzalloc(dev, sizeof(*reader), GFP_KERNEL);
	reader->bldev = bldev;
	reader->buf = NULL;
	reader->pos = 0;
	reader->remaining = 0;

	filp->private_data = reader;

	/* The buffers will be mapped/resubmitted at the time of allocation
	 * Here, we just map the first buffer */
	if (!bldev->buffers)
    {
        dev_err(dev, "can't allocate memory\n");
        return -ENOMEM;
    }

	beagledvbspi_map_buffer(dev, &bldev->buffers[0]);

	return 0;
}

/* Read the sample (ring) buffer. */
ssize_t beagledvbspi_f_read (struct file *filp, char __user *buf,
                          size_t sz, loff_t *offset)
{
	int count;
	struct logic_buffer_reader *reader = filp->private_data;
	struct beagledvbspidev *bldev = reader->bldev;
	struct device *dev = bldev->miscdev.this_device;

	if (bldev->state == STATE_BL_ERROR)
		return -EIO;

	if (reader->pos > 0)
		goto perform_copy;

	if (reader->buf == NULL) {
		/* First time init */
		reader->buf = &reader->bldev->buffers[0];
		reader->remaining = reader->buf->size;

		if (bldev->state != STATE_BL_RUNNING) {
			/* Start the capture */
			if (beagledvbspi_start(dev))
				return -ENOEXEC;
		}
	} else {
		/* EOF Condition, back to buffer 0 and stopped */
		if (reader->buf == bldev->buffers &&
				bldev->state == STATE_BL_INITIALIZED)
			return 0;
	}

	if (filp->f_flags & O_NONBLOCK) {
		if (reader->buf->state != STATE_BL_BUF_UNMAPPED)
			return -EAGAIN;
	} else {
		if (wait_event_interruptible(bldev->wait,
				reader->buf->state == STATE_BL_BUF_UNMAPPED))
			return -ERESTARTSYS;
	}
perform_copy:
	count = min(reader->remaining, sz);

    dev_warn(dev, "read address %p, count %d\n", reader->buf->buf + reader->pos, count);
    dev_warn(dev, "0x%x, 0x%x\n", reader->buf->buf + reader->pos, reader->buf->buf + reader->pos +1);

	if (copy_to_user(buf, reader->buf->buf + reader->pos, count))
		return -EFAULT;

	/* Detect buffer drop */
	if (reader->buf->state == STATE_BL_BUF_MAPPED) {
		dev_warn(dev, "buffer may be dropped at index %d \n",
				reader->buf->index);
		reader->buf->state = STATE_BL_BUF_DROPPED;
		bldev->lasterror = 0x10000 | reader->buf->index;
	}

	reader->pos += count;
	reader->remaining -= count;

	if (reader->remaining == 0) {
		/* Change the buffer */
		reader->buf = reader->buf->next;
		reader->pos = 0;
		reader->remaining = reader->buf->size;
	}

	return count;
}

/* Map the PRU buffers to user space [cache coherency managed by driver] */
int beagledvbspi_f_mmap(struct file *filp, struct vm_area_struct *vma)
{
	int i, ret;
	struct logic_buffer_reader *reader = filp->private_data;
	struct beagledvbspidev *bldev = reader->bldev;

	unsigned long addr = vma->vm_start;

	if (vma->vm_end - vma->vm_start > bldev->bufunitsize * bldev->bufcount)
		return -EINVAL;

	for (i = 0; i < bldev->bufcount; i++) {
		ret = remap_pfn_range(vma, addr,
				(bldev->buffers[i].phys_addr) >> PAGE_SHIFT,
				bldev->buffers[i].size,
				vma->vm_page_prot);

		if (ret)
			return -EINVAL;

		addr += bldev->buffers[i].size;
	}
	return 0;
}

/* Configuration through ioctl */
static long beagledvbspi_f_ioctl(struct file *filp, unsigned int cmd,
		  unsigned long arg)
{
	struct logic_buffer_reader *reader = filp->private_data;
	struct beagledvbspidev *bldev = reader->bldev;
	struct device *dev = bldev->miscdev.this_device;

	uint32_t val;

	dev_dbg(dev, "Beagledvbspi: IOCTL called cmd = %08X, "\
			"arg = %08lX\n", cmd, arg);

	switch (cmd) {
		case IOCTL_BL_GET_VERSION:
			return 0;

		case IOCTL_BL_GET_CUR_INDEX:
			if (copy_to_user((void * __user)arg,
					&bldev->bufbeingread->index,
					sizeof(bldev->bufbeingread->index)))
				return -EFAULT;
			return 0;

		case IOCTL_BL_CACHE_INVALIDATE:
			for (val = 0; val < bldev->bufcount; val++) {
				beagledvbspi_unmap_buffer(dev,
						&bldev->buffers[val]);
			}
			return 0;

		case IOCTL_BL_GET_BUFFER_SIZE:
			val = bldev->bufunitsize * bldev->bufcount;
			if (copy_to_user((void * __user)arg,
					&val,
					sizeof(val)))
				return -EFAULT;
			return 0;

		case IOCTL_BL_SET_BUFFER_SIZE:
			beagledvbspi_memfree(dev);
			val = beagledvbspi_memalloc(dev, arg);
			if (!val)
				return beagledvbspi_map_and_submit_all_buffers(dev);
			return val;

		case IOCTL_BL_GET_BUFUNIT_SIZE:
			if (copy_to_user((void * __user)arg,
					&bldev->bufunitsize,
					sizeof(bldev->bufunitsize)))
				return -EFAULT;
			return 0;

		case IOCTL_BL_SET_BUFUNIT_SIZE:
			if ((uint32_t)arg < 32)
				return -EINVAL;
			bldev->bufunitsize = round_up(arg, 32);
			beagledvbspi_memfree(dev);
			return 0;

		case IOCTL_BL_FILL_TEST_PATTERN:
			beagledvbspi_fill_buffer_testpattern(dev);
			return 0;

		case IOCTL_BL_START:
			/* Reset and reconfigure the reader object and then start */
			reader->buf = &bldev->buffers[0];
			reader->pos = 0;
			reader->remaining = reader->buf->size;

			beagledvbspi_start(dev);
			return 0;

		case IOCTL_BL_STOP:
			beagledvbspi_stop(dev);
			return 0;

	}
	return -ENOTTY;
}

/* llseek to offset zero resets the LA */
static loff_t beagledvbspi_f_llseek(struct file *filp, loff_t offset, int whence)
{
	struct logic_buffer_reader *reader = filp->private_data;
	struct beagledvbspidev *bldev = reader->bldev;
	struct device *dev = bldev->miscdev.this_device;

	loff_t i = offset;
	uint32_t j;

	if (whence == SEEK_CUR) {
		while (i > 0) {
			if (reader->buf->state == STATE_BL_BUF_MAPPED) {
				dev_warn(dev, "buffer may be dropped at index %d \n",
						reader->buf->index);
				reader->buf->state = STATE_BL_BUF_DROPPED;
				bldev->lasterror = 0x10000 | reader->buf->index;
			}

			j = min((uint32_t)i, reader->remaining);
			reader->pos += j;

			if ((reader->remaining -= j) == 0) {
				/* Change the buffer */
				reader->buf = reader->buf->next;
				reader->pos = 0;
				reader->remaining = reader->buf->size;
			}

			i -= j;
		}
		return offset;
	}

	if (whence == SEEK_SET && offset == 0) {
		/* The next read triggers the LA */
		reader->buf = NULL;
		reader->pos = 0;
		reader->remaining = 0;

		/* Stop and map the first buffer */
		beagledvbspi_stop(dev);
		beagledvbspi_map_buffer(dev, &reader->bldev->buffers[0]);

		return 0;
	}

	return -EINVAL;
}

/* Poll the file descriptor */
unsigned int beagledvbspi_f_poll(struct file *filp,
		struct poll_table_struct *tbl)
{
	struct logic_buffer_reader *reader = filp->private_data;
	struct beagledvbspidev *bldev = reader->bldev;
	struct logic_buffer *buf;

	/* Raise an error if polled without starting the LA first */
	if (reader->buf == NULL && bldev->state != STATE_BL_RUNNING)
		return -ENOEXEC;

	buf = reader->buf;
	if (buf->state == STATE_BL_BUF_UNMAPPED)
		return (POLLIN | POLLRDNORM);

	poll_wait(filp, &bldev->wait, tbl);

	return 0;
}

/* Device file close handler */
static int beagledvbspi_f_release(struct inode *inode, struct file *filp)
{
	struct logic_buffer_reader *reader = filp->private_data;
	struct beagledvbspidev *bldev = reader->bldev;
	struct device *dev = bldev->miscdev.this_device;

	/* Stop & Release */
	beagledvbspi_stop(dev);
	devm_kfree(dev, reader);

	return 0;
}

/* File operations struct */
static const struct file_operations pru_beagledvbspi_fops = {
	.owner = THIS_MODULE,
	.open = beagledvbspi_f_open,
	.unlocked_ioctl = beagledvbspi_f_ioctl,
	.read = beagledvbspi_f_read,
	.llseek = beagledvbspi_f_llseek,
	.mmap = beagledvbspi_f_mmap,
	.poll = beagledvbspi_f_poll,
	.release = beagledvbspi_f_release,
};
/* fops */

/* begin sysfs attrs */
static ssize_t bl_bufunitsize_show(struct device *dev,
        struct device_attribute *attr, char *buf)
{
	struct beagledvbspidev *bldev = dev_get_drvdata(dev);

	return scnprintf(buf, PAGE_SIZE, "%d\n", bldev->bufunitsize);
}

static ssize_t bl_bufunitsize_store(struct device *dev,
        struct device_attribute *attr, const char *buf, size_t count)
{
	struct beagledvbspidev *bldev = dev_get_drvdata(dev);
	uint32_t val;

	if (kstrtouint(buf, 10, &val))
		return -EINVAL;

	if (val < 32)
		return -EINVAL;

	bldev->bufunitsize = round_up(val, 32);

	/* Free up previously allocated buffers */
	beagledvbspi_memfree(dev);

	return count;
}

static ssize_t bl_memalloc_show(struct device *dev,
        struct device_attribute *attr, char *buf)
{
	struct beagledvbspidev *bldev = dev_get_drvdata(dev);

	return scnprintf(buf, PAGE_SIZE, "%d\n",
			bldev->bufcount * bldev->bufunitsize);
}

static ssize_t bl_memalloc_store(struct device *dev,
        struct device_attribute *attr, const char *buf, size_t count)
{
	struct beagledvbspidev *bldev = dev_get_drvdata(dev);
	uint32_t val;
	int ret;

	if (kstrtouint(buf, 10, &val))
		return -EINVAL;

	/* Check value of memory to reserve */
	if (val > bldev->maxbufcount * bldev->bufunitsize)
		return -EINVAL;

	/* Free buffers and reallocate */
	beagledvbspi_memfree(dev);
	ret = beagledvbspi_memalloc(dev, val);

	if (!ret)
		beagledvbspi_map_and_submit_all_buffers(dev);
	else
		return ret;

	return count;
}

static ssize_t bl_state_show(struct device *dev,
		struct device_attribute *attr, char *buf)
{
	struct beagledvbspidev *bldev = dev_get_drvdata(dev);
	uint32_t state = bldev->state;
	struct logic_buffer *buffer = bldev->bufbeingread;

	if (state == STATE_BL_RUNNING) {
		/* State blocks and returns last buffer read */
		wait_event_interruptible(bldev->wait,
				buffer->state == STATE_BL_BUF_UNMAPPED);
		return scnprintf(buf, PAGE_SIZE, "%d\n", buffer->index);
	}

	/* Identify non-buffer debug states with a -ve value */
	return scnprintf(buf, PAGE_SIZE, "-%d\n", -bldev->state);
}

static ssize_t bl_state_store(struct device *dev,
		struct device_attribute *attr, const char *buf, size_t count)
{
	uint32_t val;

	if (kstrtouint(buf, 10, &val))
		return -EINVAL;

	/* State going to 1 starts the sampling operation, 0 aborts*/
	if (val > 1)
		return -EINVAL;

	if (val == 1)
		beagledvbspi_start(dev);
	else
		beagledvbspi_stop(dev);

	return count;
}

static ssize_t bl_buffers_show(struct device *dev,
		struct device_attribute *attr, char *buf)
{
	struct beagledvbspidev *bldev = dev_get_drvdata(dev);
	int i, c, cnt;

	for (i = 0, c = 0, cnt = 0; i < bldev->bufcount; i++) {
		c = scnprintf(buf, PAGE_SIZE, "%08x,%u\n",
				(uint32_t)bldev->buffers[i].phys_addr,
				bldev->buffers[i].size);
		cnt += c;
		buf += c;
	}

	return cnt;
}

static ssize_t bl_lasterror_show(struct device *dev,
		struct device_attribute *attr, char *buf)
{
	struct beagledvbspidev *bldev = dev_get_drvdata(dev);

	wait_event_interruptible(bldev->wait,
			bldev->state != STATE_BL_RUNNING);


	return scnprintf(buf, PAGE_SIZE, "%d\n", bldev->lasterror);
}

static ssize_t bl_testpattern_store(struct device *dev,
		struct device_attribute *attr, const char *buf, size_t count)
{
	uint32_t val;

	if (kstrtouint(buf, 10, &val))
		return -EINVAL;

	/* Only if we get the magic number, trigger the test pattern */
	if (val == 12345678)
		beagledvbspi_fill_buffer_testpattern(dev);

	return count;
}

static DEVICE_ATTR(bufunitsize, S_IWUSR | S_IRUGO,
		bl_bufunitsize_show, bl_bufunitsize_store);

static DEVICE_ATTR(memalloc, S_IWUSR | S_IRUGO,
		bl_memalloc_show, bl_memalloc_store);

static DEVICE_ATTR(state, S_IWUSR | S_IRUGO,
		bl_state_show, bl_state_store);

static DEVICE_ATTR(buffers, S_IRUGO,
		bl_buffers_show, NULL);

static DEVICE_ATTR(lasterror, S_IRUGO,
		bl_lasterror_show, NULL);

static DEVICE_ATTR(filltestpattern, S_IWUSR,
		NULL, bl_testpattern_store);

static struct attribute *beagledvbspi_attributes[] = {
	&dev_attr_bufunitsize.attr,
	&dev_attr_memalloc.attr,
	&dev_attr_state.attr,
	&dev_attr_buffers.attr,
	&dev_attr_lasterror.attr,
	&dev_attr_filltestpattern.attr,
	NULL
};

static struct attribute_group beagledvbspi_attr_group = {
	.attrs = beagledvbspi_attributes
};
/* end sysfs attrs */

static const struct of_device_id beagledvbspi_dt_ids[];

static int beagledvbspi_probe(struct platform_device *pdev)
{
	struct beagledvbspidev *bldev;
	struct device *dev;
	struct device_node *node = pdev->dev.of_node;
	const struct of_device_id *match;
	int ret;

	if (!node)
		return -ENODEV; /* No support for non-DT platforms */

	match = of_match_device(beagledvbspi_dt_ids, &pdev->dev);
	if (!match)
		return -ENODEV;

	/* Allocate memory for our private structure */
	bldev = kzalloc(sizeof(*bldev), GFP_KERNEL);
	if (!bldev) {
		ret = -1;
		goto fail;
	}

	bldev->fw_data = match->data;
	bldev->miscdev.fops = &pru_beagledvbspi_fops;
	bldev->miscdev.minor = MISC_DYNAMIC_MINOR;
	bldev->miscdev.mode = S_IRUGO;
	bldev->miscdev.name = "beagledvbspi";

	/* Link the platform device data to our private structure */
	bldev->p_dev = &pdev->dev;
	dev_set_drvdata(bldev->p_dev, bldev);

	/* Get a handle to the PRUSS structures */
	dev = &pdev->dev;
	bldev->pruss = pruss_get(dev, NULL);
	if (IS_ERR(bldev->pruss)) {
		ret = PTR_ERR(bldev->pruss);
		if (ret != -EPROBE_DEFER)
			dev_err(dev, "Unable to get pruss handle.\n");
		goto fail_free;
	}

	bldev->pru0 = pruss_rproc_get(bldev->pruss, PRUSS_PRU0);
	if (IS_ERR(bldev->pru0)) {
		ret = PTR_ERR(bldev->pru0);
		if (ret != -EPROBE_DEFER)
			dev_err(dev, "Unable to get PRU0.\n");
		goto fail_pruss_put;
	}

	bldev->pru1 = pruss_rproc_get(bldev->pruss, PRUSS_PRU1);
	if (IS_ERR(bldev->pru1)) {
		ret = PTR_ERR(bldev->pru1);
		if (ret != -EPROBE_DEFER)
			dev_err(dev, "Unable to get PRU0.\n");
		goto fail_pru0_put;
	}

	ret = pruss_request_mem_region(bldev->pruss, PRUSS_MEM_DRAM0,
		&bldev->pru0sram);
	if (ret) {
		dev_err(dev, "Unable to get PRUSS RAM.\n");
		goto fail_putmem;
	}

	/* Get interrupts and install interrupt handlers */
	bldev->from_bl_irq_1 = platform_get_irq_byname(pdev, "from_bl_1");
	if (bldev->from_bl_irq_1 <= 0) {
		ret = bldev->from_bl_irq_1;
		if (ret == -EPROBE_DEFER)
			goto fail_putmem;
	}
	bldev->from_bl_irq_2 = platform_get_irq_byname(pdev, "from_bl_2");
	if (bldev->from_bl_irq_2 <= 0) {
		ret = bldev->from_bl_irq_2;
		if (ret == -EPROBE_DEFER)
			goto fail_putmem;
	}
	bldev->to_bl_irq = platform_get_irq_byname(pdev, "to_bl");
	if (bldev->to_bl_irq<= 0) {
		ret = bldev->to_bl_irq;
		if (ret == -EPROBE_DEFER)
			goto fail_putmem;
	}

	ret = request_irq(bldev->from_bl_irq_1, beagledvbspi_serve_irq,
		IRQF_ONESHOT, dev_name(dev), bldev);
	if (ret) goto fail_putmem;

	ret = request_irq(bldev->from_bl_irq_2, beagledvbspi_serve_irq,
		IRQF_ONESHOT, dev_name(dev), bldev);
	if (ret) goto fail_free_irq1;

	/* Set firmware and boot the PRUs */
	ret = rproc_set_firmware(bldev->pru0, bldev->fw_data->fw_names[0]);
	if (ret) {
		dev_err(dev, "Failed to set PRU0 firmware %s: %d\n",
			bldev->fw_data->fw_names[0], ret);
		goto fail_free_irqs;
	}

	ret = rproc_set_firmware(bldev->pru1, bldev->fw_data->fw_names[1]);
	if (ret) {
		dev_err(dev, "Failed to set PRU1 firmware %s: %d\n",
			bldev->fw_data->fw_names[1], ret);
		goto fail_free_irqs;
	}

	ret = rproc_boot(bldev->pru0);
	if (ret) {
		dev_err(dev, "Failed to boot PRU0: %d\n", ret);
		goto fail_free_irqs;
	}

	ret = rproc_boot(bldev->pru1);
	if (ret) {
		dev_err(dev, "Failed to boot PRU1: %d\n", ret);
		goto fail_shutdown_pru0;
	}

	printk("Beagledvbspi loaded and initializing\n");

	/* Once done, register our misc device and link our private data */
	ret = misc_register(&bldev->miscdev);
	if (ret)
		goto fail_shutdown_prus;
	dev = bldev->miscdev.this_device;
	dev_set_drvdata(dev, bldev);

	/* Set up locks */
	mutex_init(&bldev->mutex);
	init_waitqueue_head(&bldev->wait);

	/* Core clock frequency is 200 MHz */
	bldev->coreclockfreq = 200000000;

	/* Power on in disabled state */
	bldev->state = STATE_BL_DISABLED;

	/* Capture context structure is at location 0000h in PRU0 SRAM */
	bldev->cxt_pru = bldev->pru0sram.va + 0;

	if (bldev->cxt_pru->magic == BL_FW_MAGIC)
		dev_info(dev, "Valid PRU capture context structure "\
				"found at offset %04X\n", 0);
	else {
		dev_err(dev, "Firmware error!\n");
		goto faildereg;
	}

	/* Get firmware properties */
	ret = beagledvbspi_send_cmd(bldev, CMD_GET_VERSION);
	if (ret != 0) {
		dev_info(dev, "Beagledvbspi PRU Firmware version: %d.%d\n",
				ret >> 8, ret & 0xFF);
	} else {
		dev_err(dev, "Firmware error!\n");
		goto faildereg;
	}

	ret = beagledvbspi_send_cmd(bldev, CMD_GET_MAX_SG);
	if (ret > 0 && ret < 256) { /* Let's be reasonable here */
		dev_info(dev, "Device supports max %d vector transfers\n", ret);
		bldev->maxbufcount = ret;
	} else {
		dev_err(dev, "Firmware error!\n");
		goto faildereg;
	}

	/* Apply default configuration first */
	bldev->bufunitsize = 4 * 1024 * 1024;
    bldev->triggerflags = 1;

	/* We got configuration from PRUs, now mark device init'd */
	bldev->state = STATE_BL_INITIALIZED;

	/* Display our init'ed state */
	dev_info(dev, "Default: Buffer in units of %d bytes each\n", bldev->bufunitsize);

	/* Once done, create device files */
	ret = sysfs_create_group(&dev->kobj, &beagledvbspi_attr_group);
	if (ret) {
		dev_err(dev, "Registration failed.\n");
		goto faildereg;
	}

	return 0;
faildereg:
	misc_deregister(&bldev->miscdev);
fail_shutdown_prus:
	rproc_shutdown(bldev->pru1);
fail_shutdown_pru0:
	rproc_shutdown(bldev->pru0);
fail_free_irqs:
	free_irq(bldev->from_bl_irq_2, bldev);
fail_free_irq1:
	free_irq(bldev->from_bl_irq_1, bldev);
fail_putmem:
	if (bldev->pru0sram.va)
		pruss_release_mem_region(bldev->pruss, &bldev->pru0sram);
	pruss_rproc_put(bldev->pruss, bldev->pru1);
fail_pru0_put:
	pruss_rproc_put(bldev->pruss, bldev->pru0);
fail_pruss_put:
	pruss_put(bldev->pruss);
fail_free:
	kfree(bldev);
fail:
	return ret;
}

static int beagledvbspi_remove(struct platform_device *pdev)
{
	struct beagledvbspidev *bldev = platform_get_drvdata(pdev);
	struct device *dev = bldev->miscdev.this_device;

	/* Free all buffers */
	beagledvbspi_memfree(dev);

	/* Remove the sysfs attributes */
	sysfs_remove_group(&dev->kobj, &beagledvbspi_attr_group);

	/* Deregister the misc device */
	misc_deregister(&bldev->miscdev);

	/* Shutdown the PRUs */
	rproc_shutdown(bldev->pru1);
	rproc_shutdown(bldev->pru0);

	/* Free IRQs */
	free_irq(bldev->from_bl_irq_2, bldev);
	free_irq(bldev->from_bl_irq_1, bldev);

	/* Release handles to PRUSS memory regions */
	pruss_release_mem_region(bldev->pruss, &bldev->pru0sram);
	pruss_rproc_put(bldev->pruss, bldev->pru1);
	pruss_rproc_put(bldev->pruss, bldev->pru0);
	pruss_put(bldev->pruss);

	/* Free up memory */
	kfree(bldev);

	/* Print a log message to announce unloading */
	printk("Beagledvbspi unloaded\n");
	return 0;
}

static struct beagledvbspi_private_data beagledvbspi_pdata = {
	.fw_names[0] = "beagledvbspi-pru0-fw",
	.fw_names[1] = "beagledvbspi-pru1-fw",
};

static const struct of_device_id beagledvbspi_dt_ids[] = {
	{ .compatible = "beagledvbspi,beagledvbspi", .data = &beagledvbspi_pdata, },
	{ /* sentinel */ },
};
MODULE_DEVICE_TABLE(of, beagledvbspi_dt_ids);

static struct platform_driver beagledvbspi_driver = {
	.driver = {
		.name = DRV_NAME,
		.owner = THIS_MODULE,
		.of_match_table = beagledvbspi_dt_ids,
	},
	.probe = beagledvbspi_probe,
	.remove = beagledvbspi_remove,
};

module_platform_driver(beagledvbspi_driver);

MODULE_AUTHOR("Kumar Abhishek / R Colomban");
MODULE_DESCRIPTION("Kernel Driver for BeagleDVB-SPI");
MODULE_LICENSE("GPL");
MODULE_VERSION(DRV_VERSION);
