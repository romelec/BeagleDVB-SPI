#!/bin/bash

# Install script for BeagleDVB-SPI from git repository
#
# This script is meant to be executed in either a chroot environment (used while
# building the BeagleDVB-SPI system image) or after doing a git clone of the
# BeagleDVB-SPI repository.
#
# This script only supports the BeagleBone Debian image which have all the
# required dependencies

DIR=$(cd `dirname $0` && pwd -P)
log="beagledvbspi:"

# The kernel looks for beagledvbspi-pru0-fw and beagledvbspi-pru1-fw in /lib/firmware
# The firmware is installed as 'beagledvbspi-pru0-fw' and 'beagledvbspi-pru1-logic'
# beagledvbspi-pru1-fw is further symlinked to beagledvbspi-pru1-logic
# This arrangement enables running PRUDAQ by simply updating the symlink and
# reloading the beagledvbspi kernel module
install_pru_firmware () {
	# Required for compiling the firmware, see firmware/Makefile
	if [ ! -d /usr/share/ti/cgt-pru/bin ] ; then
		ln -s /usr/bin/ /usr/share/ti/cgt-pru/bin
	fi

	echo "${log} Building and installing PRU firmware"
	export PRU_CGT=/usr/share/ti/cgt-pru
	cd "${DIR}/firmware"
	make
	make install

	if [ ! "x${RUNNING_AS_CHROOT}" = "xyes" ] ; then
		update-initramfs -u -k `uname -r`
	fi
}

create_beagledvbspi_group() {
	echo "${log} Creating beagledvbspi group and adding $DEFAULT_USER to it"

	groupadd -f beagledvbspi
	usermod -aG beagledvbspi ${DEFAULT_USER}
}

# Udev rules required to allow the default user to modify BeagleDVB-SPI
# sysfs attributes without requiring root permissions
install_udev_rules() {
	echo "${log} Installing udev rules"
	cp -v "${DIR}/scripts/90-beagledvbspi.rules" "/etc/udev/rules.d/"
}

install_systemd_service() {
	echo "${log} Installing systemd startup service"
	cp -v "${DIR}/scripts/beagledvbspi" "/etc/default/beagledvbspi"
	cp -v "${DIR}/scripts/beagledvbspi.service" "/lib/systemd/system/beagledvbspi.service"
	cp -v "${DIR}/scripts/beagledvbspi-startup.service" "/lib/systemd/system/beagledvbspi-startup.service"
	chown root:root "/lib/systemd/system/beagledvbspi.service"
	chown root:root "/lib/systemd/system/beagledvbspi-startup.service"
	sed -i -e "s:DIR:${DIR}:" "/lib/systemd/system/beagledvbspi.service"
	sed -i -e "s:DIR:${DIR}:" "/lib/systemd/system/beagledvbspi-startup.service"
	systemctl enable beagledvbspi.service || true
	systemctl enable beagledvbspi-startup.service || true
}

update_uboot_uenv_txt() {
	if [ ! "x${RUNNING_AS_CHROOT}" = "xyes" ] ; then
		echo "${log} Updating uEnv.txt"
		sed -i -e "s:#disable_uboot_overlay_video:disable_uboot_overlay_video:" "/boot/uEnv.txt"
		sed -i -e "s:uboot_overlay_pru:#uboot_overlay_pru:" "/boot/uEnv.txt"
		echo '#Load BeagleDVB-SPI Cape' >> "/boot/uEnv.txt"
		echo 'uboot_overlay_pru=/lib/firmware/beagledvbspi-00A0.dtbo' >> "/boot/uEnv.txt"
	fi
}

display_success_message() {
	if [ ! "x${RUNNING_AS_CHROOT}" = "xyes" ] ; then
		echo "${log} Successfully Installed. Please reboot"
	else
		echo "${log} Installation Completed, uEnv.txt must be updated"
	fi
}


if [ "x$1" = "x--upgrade" ] ; then
	UPGRADING="yes"
else
	UPGRADING="no"
fi

if [ "x$1" = "x--update-uenv-txt" ] ; then
	update_uboot_uenv_txt
	exit 0
fi

if [ "x$1" = "x--chroot" ] ; then
	DEFAULT_USER=$2
	RUNNING_AS_CHROOT="yes"
else
	RUNNING_AS_CHROOT="no"
	if [ ! "x$SUDO_USER" = "x" ] ; then
		DEFAULT_USER=$SUDO_USER
	else
		DEFAULT_USER="debian"
	fi
fi

install_pru_firmware
if [ "x${UPGRADING}" = "xno" ] ; then
	create_beagledvbspi_group
fi
install_udev_rules
install_systemd_service

if [ "x${UPGRADING}" = "xno" ] ; then
	update_uboot_uenv_txt
fi
display_success_message
