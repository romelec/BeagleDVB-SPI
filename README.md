BeagleDVB-SPI is a DVB-SPI interface on the BeagleBone Black to record/analyze TS streams.

This project is based on [BeagleLogic](https://github.com/abhishek-kakkar/BeagleLogic)

It uses the Programmable Real-Time units and matching firmware and Linux kernel modules on the
BeagleBone Black.

This is a work in progress, it kinda works but misses some data.

Directories:

* firmware: PRU Firmware
* kernel: Device Tree overlay source and kernel module source and Makefile.
* cape: The cape design files done with KiCAD

* parsing: An application to get the data and parse it to have usable TS stream
2 parameters: in and out file, generally /dev/beagledvbspi and the ouput ts file

License
--------

 * **PRU firmware & Device tree overlay** : GPLv2
 * **Kernel Module**: GPLv2
 * **Cape** : CERN Open Hardware License
