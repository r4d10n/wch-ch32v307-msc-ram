# wch-ch32v307-msc-ram

## Overview

This repository contains a CherryUSB based USB-MSC demo implementation for the [WCH CH32V307V-EVT-R1 development board](https://github.com/openwch/ch32v307) running the CH32V307 RISC-V microcontroller. 
This repository is based on the [CherryUSB](https://github.com/sakumisu/CherryUSB) project, which provides portable USB Host and Device stack for microcontrollers. 

The project uses:

* [Mounriver Studio Toolchain Bundle](http://file.mounriver.com/tools/MRS_Toolchain_Linux_x64_V1.30.tar.xz)
  * GCC RISC-V Compiler and Debugger (riscv-none-embed-)
  * OpenOCD-WCH (Debug)
  
## User Guide

### Setup

* Install the toolchain bundle downloaded from the Mounriver website. Edit Makefile to change path variables `TOOLCHAIN_ROOT` and `OPENOCD_ROOT` to the gcc toolchain and openocd bin directory. Rename directories to avoid spaces in path string. 
* Add the following lines to `/etc/udev/rules.d/60-openocd.rules` or similar. Run `sudo udevadm control --reload` and replug device to USB.
 
            SUBSYSTEM=="usb", ATTR{idVendor}="1a86", ATTR{idProduct}=="8010", GROUP="plugdev"
    
* Add the following line to `~/.gdbinit`, so as to enable auto gdb initialization. Modify `<path>` to point to current directory.

            add-auto-load-safe-path <path>/wch-ch32v307-makefile/.gdbinit
    
* Connect USB-C Cable to P9 for programming, debugging and log output.
* Connect USB-C Cable to P9 for USB MSC device.
    
### Build and Debug

* Simply run `make` to build the project.
* Run `make prog` to build the project and program the firmware using openocd.
* Run `sudo dmesg` to see status about the USB MSC Device. `sudo fdisk -l` will also list the pseudo-device.

For Debugging:

* In another terminal, start the GDB server by running `make gdb-server_openocd`.  GDB Server probably has to be restarted after every code download step, otherwise seems to hang. 
* Run `make gdb-client` to download the code and start debugging.

