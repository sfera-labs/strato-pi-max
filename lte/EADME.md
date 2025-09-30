# LTE module setup and usage

When Strato Pi Max is equipped with a M.2 LTE Module expansion board with the Telit LN920 module, it will appear on the USB 2.0 bus of the Compute Module:

```
$ lsusb
Bus 005 Device 005: ID 1bc7:1060 Telit Wireless Solutions LN920
[...]
```

Below are some examples on how to setup a connection through the LTE module and access other functionalities via AT commands.

## LTE Connection

To setup a connection you'll need to retrieve the **APN name** of the network provider of your SIM card.
Below we'll use `myapn` as an example.

### Option 1: NetworkManager / ModemManager

Add a new connection using `nmcli`, here we call it `mygsm`:

```
sudo nmcli connection add type gsm ifname '*' con-name 'mygsm' apn 'myapn' connection.autoconnect yes
```

The corresponding configuration will be saved in `/etc/NetworkManager/system-connections/mygsm.nmconnection`.

The modem will connect automatically upon reboot.

Check the connection state with `nmcli device show cdc-wdm0`, e.g.:

```
$ nmcli device show cdc-wdm0
GENERAL.DEVICE:                         cdc-wdm0
GENERAL.TYPE:                           gsm
GENERAL.HWADDR:                         (unknown)
GENERAL.MTU:                            1420
GENERAL.STATE:                          100 (connected)
GENERAL.CONNECTION:                     gsm
GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/ActiveConnection/3
IP4.ADDRESS[1]:                         10.94.65.235/29
IP4.GATEWAY:                            10.94.65.236
IP4.ROUTE[1]:                           dst = 10.94.65.232/29, nh = 0.0.0.0, mt = 700
IP4.ROUTE[2]:                           dst = 0.0.0.0/0, nh = 10.94.65.236, mt = 700
IP4.DNS[1]:                             81.178.120.241
IP4.DNS[2]:                             81.178.120.240
IP6.GATEWAY:                            --
```

Use `mmcli` to get modem and SIM info:

```
$ mmcli --list-modems
    /org/freedesktop/ModemManager1/Modem/0 [Telit] LN920A6-WW
```

```
$ mmcli --modem=/org/freedesktop/ModemManager1/Modem/0
[...]
  ----------------------------------
  SIM      |       primary sim path: /org/freedesktop/ModemManager1/SIM/0
           |         sim slot paths: slot 1: /org/freedesktop/ModemManager1/SIM/0 (active)
           |                         slot 2: none
  ----------------------------------
[...]
```

```
$ mmcli --sim=/org/freedesktop/ModemManager1/SIM/0
  -------------------------------
  General    |              path: /org/freedesktop/ModemManager1/SIM/0
  -------------------------------
  Properties |            active: yes
             |              imsi: XXXXXXXXXXXXXXX
             |             iccid: YYYYYYYYYYYYYYYYYYY
             |       operator id: 99999
             |     operator name: MYOPERATOR
             |              gid1: AAAA
             |              gid2: BBBBBBBB
```

To select the SIM in slot 2 run:

```
sudo mmcli --modem=/org/freedesktop/ModemManager1/Modem/0 --set-primary-sim-slot=2
```
