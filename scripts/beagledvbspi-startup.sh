#!/bin/bash

log='beagledvbspi-startup:'
SLOTS="/sys/devices/platform/bone_capemgr/slots"

check_uboot_overlay=$(grep bone_capemgr.uboot_capemgr_enabled=1 /proc/cmdline || true)
if [ ! -d /sys/devices/virtual/misc/beagledvbspi ] ; then
	if [ "x${check_uboot_overlay}" = "x" ] ; then
		echo beagledvbspi > "${SLOTS}"
		echo cape-universalh > "${SLOTS}"
	fi

	echo "${log} Waiting for BeagleDVB-SPI to show up (timeout in 120 seconds)"
	wait_seconds=120
	until test $((wait_seconds--)) -eq 0 -o -d "/sys/devices/virtual/misc/beagledvbspi" ; do sleep 1; done
	if [ ! -d /sys/devices/virtual/misc/beagledvbspi ] ; then
		echo "${log} timeout. BeagleDVB-SPI couldn't load."
		exit 1
	fi
fi

echo "${log} Configuring LA pins"
config-pin -f $(dirname $0)/pinconfig

echo "${log} Allocating 64MiB of logic buffer to BeagleDVB-SPI"
echo 67108864 > /sys/devices/virtual/misc/beagledvbspi/memalloc

echo "${log} Loaded"
