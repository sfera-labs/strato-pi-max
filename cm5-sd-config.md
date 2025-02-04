# Compute Module 5 SD card compatibility

The Compute Module 5 features a high-speed SD interface, which may cause compatibility issues with SD cards that support these speeds when connected through Srato Pi Max XL's SD matrix.

To ensure compatibility, both the Compute Module's bootloader and the OS must be configured to avoid using these settings.

## Bootloader

Make sure the bootloader of your Compute Module is updated to the latest version, then add this property to its configuration:

```
SD_QUIRKS=0x1
```

For more details refero to: [Raspberry Pi bootloader configuration](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#raspberry-pi-bootloader-configuration)

## Device Tree

Below is the procedure for modifying the Device Tree on Raspberry Pi OS.

Check the currently used Device Tree file:

```
sudo vclog -m | grep dtb_file
```

Example output:

```
006220.319: dtb_file 'bcm2712-rpi-cm5l-cm5io.dtb'
```

Backup the original dtb file, e.g.:

```
cp /boot/firmware/bcm2712-rpi-cm5l-cm5io.dtb ~/.
```

Decompile the dtb (ignore warnings):

```
dtc -I dtb -O dts bcm2712-rpi-cm5l-cm5io.dtb -o ~/strato-cm5.dts
```

Find the node corresponding to `sdio1`:

```
grep 'sdio1 =' ~/strato-cm5.dts
```

Example output:

```
		sdio1 = "/axi/mmc@fff000";
```

Edit the dts:

```
nano ~/strato-cm5.dts
```

Go to the node found above (Use search: <kbd>^</kbd><kbd>W</kbd> `mmc@fff000`):

```
                mmc@fff000 {
                        compatible = "brcm,bcm2712-sdhci";
                        reg = <0x10 0xfff000 0x00 0x260 0x10 0xfff400 0x00 0x200 0x10 0x15040b0 0x00 0x04 0x10 0x15200f0 0x00 0x24>;
                        reg-names = "host\0cfg\0busisol\0lcpll";
                        interrupts = <0x00 0x111 0x04>;
                        clocks = <0x54>;
                        sdhci-caps-mask = <0xc000 0x00>;
                        sdhci-caps = <0x00 0x00>;
                        mmc-ddr-3_3v;
                        pinctrl-0 = <0x55 0x56>;
                        pinctrl-names = "default";
                        vqmmc-supply = <0x57>;
                        vmmc-supply = <0x58>;
                        bus-width = <0x08>;
                        sd-uhs-sdr50;
                        sd-uhs-ddr50;
                        sd-uhs-sdr104;
                        mmc-hs200-1_8v;
                        broken-cd;
                        supports-cqe;
                        status = "okay";
                        phandle = <0x10c>;
                };
```

Remove the `sd-uhs-*` nodes:

```
                mmc@fff000 {
                        compatible = "brcm,bcm2712-sdhci";
                        reg = <0x10 0xfff000 0x00 0x260 0x10 0xfff400 0x00 0x200 0x10 0x15040b0 0x00 0x04 0x10 0x15200f0 0x00 0x24>;
                        reg-names = "host\0cfg\0busisol\0lcpll";
                        interrupts = <0x00 0x111 0x04>;
                        clocks = <0x54>;
                        sdhci-caps-mask = <0xc000 0x00>;
                        sdhci-caps = <0x00 0x00>;
                        mmc-ddr-3_3v;
                        pinctrl-0 = <0x55 0x56>;
                        pinctrl-names = "default";
                        vqmmc-supply = <0x57>;
                        vmmc-supply = <0x58>;
                        bus-width = <0x08>;
                        mmc-hs200-1_8v;
                        broken-cd;
                        supports-cqe;
                        status = "okay";
                        phandle = <0x10c>;
                };
```

Recompile the dtb (ignore warnings):

```
sudo dtc -I dts -O dtb ~/strato-cm5.dts -o ~/strato-cm5.dtb
```

Overwrite the original dtb:

```
sudo cp ~/strato-cm5.dtb /boot/firmware/bcm2712-rpi-cm5l-cm5io.dtb
```
