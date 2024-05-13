# CAN controller configuration

To enable SocketCAN support for the MCP2515 CAN controller, you need to enable and configure the SPI0 bus and the mcp2515 driver, according to the slot each expansion board is installed on.

### More than 2 CAN expansion boards

If more than 2 CAN expansion boards are installed, read this paragraph, skip it otherwise.

Download the `.dts` files in this directory and compile them:

```
dtc -@ -I dts -O dtb -o spi0-4cs.dtbo spi0-4cs-overlay.dts
dtc -@ -I dts -O dtb -o spi0-3cs.dtbo spi0-3cs-overlay.dts
dtc -@ -I dts -O dtb -o mcp2515-spi0up4.dtbo mcp2515-spi0up4-overlay.dts
```

You can ignore the `unit_address_vs_reg` warnings.

Install the generated overlays:

```
sudo cp spi0-3cs.dtbo /boot/overlays/
sudo cp spi0-4cs.dtbo /boot/overlays/
sudo cp mcp2515-spi0up4.dtbo /boot/overlays/
```

### SPI bus configuration

Enable the `spi0-Ncs` overlay in `config.txt` according to the number of used CAN expansion boards and set the chip select (`csN_pin`) parameters according to their slot number.

In the lines below replace `<CS1>` ... `<CS4>` with the slot's `csN_pin` value as per this table:

|Slot #|`csN_pin`|
|:-:|:-:|
|1|7|
|2|12|
|3|18|
|4|16|

1 expansion board:
```
dtoverlay=spi0-1cs,cs0_pin=<CS1>
```

2 expansion boards:
```
dtoverlay=spi0-2cs,cs0_pin=<CS1>,cs1_pin=<CS2>
```

3 expansion boards:
```
dtoverlay=spi0-3cs,cs0_pin=<CS1>,cs1_pin=<CS2>,cs2_pin=<CS3>

```

4 expansion boards:
```
dtoverlay=spi0-4cs,cs0_pin=<CS1>,cs1_pin=<CS2>,cs2_pin=<CS3>,cs3_pin=<CS4>
```

This links each board to a specific SPI device: `spi0-0` ... `spi0-3`

### MCP2515 driver configuration

Add a line in `config.txt` for each CAN expansion board setting the corresponding SPI device and interrupt pin.

If more than 2 CAN expansion boards are installed use the `mcp2515-spi0up4` overlay, otherwise use the `mcp2515` overlay.

In the lines below replace `<I1>` ... `<I4>` with the slot's `interrupt` value as per this table:

|Slot #|`interrupt`|
|:-:|:-:|
|1|8|
|2|13|
|3|19|
|4|17|

1 expansion board:
```
dtoverlay=mcp2515,spi0-0,oscillator=16000000,interrupt=<I1>
```

2 expansion boards:
```
dtoverlay=mcp2515,spi0-0,oscillator=16000000,interrupt=<I1>
dtoverlay=mcp2515,spi0-1,oscillator=16000000,interrupt=<I2>
```

3 expansion boards:
```
dtoverlay=mcp2515-spi0up4,spi0-0,oscillator=16000000,interrupt=<I1>
dtoverlay=mcp2515-spi0up4,spi0-1,oscillator=16000000,interrupt=<I2>
dtoverlay=mcp2515-spi0up4,spi0-2,oscillator=16000000,interrupt=<I3>
```

4 expansion boards:
```
dtoverlay=mcp2515-spi0up4,spi0-0,oscillator=16000000,interrupt=<I1>
dtoverlay=mcp2515-spi0up4,spi0-1,oscillator=16000000,interrupt=<I2>
dtoverlay=mcp2515-spi0up4,spi0-2,oscillator=16000000,interrupt=<I3>
dtoverlay=mcp2515-spi0up4,spi0-3,oscillator=16000000,interrupt=<I4>
```

After reboot you should see a new SocketCAN interface available for each installed board:

```
$ ifconfig -a
...
can0: flags=128<NOARP> mtu 16
...
can1: flags=128<NOARP> mtu 16
...
```

Note that interfaces enumeration (`can0` ... `can3`) may vary across reboots.
To find the mapping between interfaces number and SPI devices you can check the links in `/sys/class/net/` e.g.:

```
$ ls -l /sys/class/net/can*
[...] /sys/class/net/can0 -> [...]/spi_master/spi0/spi0.1/net/can0
[...] /sys/class/net/can1 -> [...]/spi_master/spi0/spi0.0/net/can1
```
