# Makefile for kernel modules and device tree script
# This file is a part of the BeagleDVB-SPI project

# Path to kernel sources relative to current directory
KSRC ?= /lib/modules/$(shell uname -r)/build

# Module targets (run from host)
obj-m := beagledvbspi.o

all:
	@make -C $(KSRC) M=$(PWD) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- modules

clean:
	@make -C $(KSRC) M=$(PWD) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- clean

# Compile and install device tree
overlay: beagledvbspi-00A0.dtbo

beagledvbspi-00A0.dtbo: beagledvbspi-00A0.dts
	dtc -O dtb -o beagledvbspi-00A0.dtbo -b 0 -@ beagledvbspi-00A0.dts

deploy_overlay:
	cp -v beagledvbspi-00A0.dtbo /lib/firmware
