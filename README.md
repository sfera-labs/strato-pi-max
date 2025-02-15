# Strato Pi Max Resources
 
[Strato Pi Max](https://www.sferalabs.cc/strato-pi-max/): the industrial, modular controller powered by the Raspberry Pi Compute Module and the RP2040 microcontroller.

## Setup Guide

Setup guide with step-by-step instructions for setting up and configuring Strato Pi Max, including OS installation, boot options, troubleshooting, and preparing the device for production.

See [Strato Pi Max Setup Guide](./setup-guide.md)

## Strato Pi Max Main Driver

Raspberry Pi OS (Debian) driver kernel module for Strato Pi Max and its expansion boards.

Go to: https://github.com/sfera-labs/strato-pi-max-kernel-module

## RTC Driver

Raspberry Pi OS (Debian) driver for Strato Pi Max's NXP PCF2131 Real Time Clock (RTC).

Go to: https://github.com/sfera-labs/rtc-pcf2131

## RP2040

The latest verison of the Strato Pi Max firmware running on the RP2040 can be downloaded here:

https://www.sferalabs.cc/files/stratopimax/fw/latest/strato_pi_max.uf2

Use the [`rpctrl.sh`](./rpctrl.sh) script to update your unit. 

Download the script and make it executable:

```
wget https://raw.githubusercontent.com/sfera-labs/strato-pi-max/master/rpctrl.sh
chmod +x rpctrl.sh
```

Run it for usage instructions:

```
./rpctrl.sh
```

The script provides additional functionalities for firmware development and testing.

## NVMe SSD

List of NVMe SSD devices tested for compatibility.

See [NVMe SSD Compatibility](./nvme-ssd-compatibility.md)

## Compute Module 5 SD Card

Guide for fixing SD card compatibility issues with Compute Module 5.

See [Compute Module 5 SD Card Compatibility](./cm5-sd-config.md)

## Expansion Boards

Refer to the user guide of your expansion board for details on how and when to use these additional resources.

### CAN

See [CAN controller configuration](./can)

## X2-Series Expansion Boards Standard Specifications

X2 is an electrical and mechanical standard developed by Sfera Labs for the design of expansion boards for the Strato Pi Max family of edge servers, as well as for future products.

See [X2-Series Standard Electrical and Mechanical Specications](https://sferalabs.cc/wp-admin/admin-ajax.php?action=download_documentation&attachment_id=1012291&filename=X2-Series-specifications.pdf&display_name=X2-Series+Standard+Electrical+and+Mechanical+Specifications)
