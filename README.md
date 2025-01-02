# Strato Pi Max resources
 
[Strato Pi Max](https://www.sferalabs.cc/strato-pi-max/): the industrial, modular controller powered by the Raspberry Pi Compute Module and the RP2040 microcontroller.

## Strato Pi Max kernel module

Raspberry Pi OS (Debian) driver for Strato Pi Max and its expansion boards.

Go to: https://github.com/sfera-labs/strato-pi-max-kernel-module

## RTC driver

Raspberry Pi OS (Debian) driver for the NXP PCF2131 Real Time Clock (RTC).

Go to: https://github.com/sfera-labs/rtc-pcf2131

## RP2040

The [`rpctrl.sh`](./rpctrl.sh) script can be used to control and update the firmware of the RP2040.

Download it and make it executable:

```
wget https://raw.githubusercontent.com/sfera-labs/strato-pi-max/master/rpctrl.sh
chmod +x rpctrl.sh
```

Run it for usage instructions:

```
./rpctrl.sh
```

## Additional resources for expansion boards

Refer to the user guide of your expansion board for details on when and how to use the these resources.

### CAN

See [CAN controller configuration](./can)
