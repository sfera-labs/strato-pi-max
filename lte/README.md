# LTE/GNSS module guide

When Strato Pi Max is equipped with a M.2 LTE Module expansion board with the Telit LN920 module, it will appear on the USB 2.0 bus of the Compute Module:

```
$ lsusb
Bus 005 Device 005: ID 1bc7:1060 Telit Wireless Solutions LN920
[...]
```

Below are some examples on how to setup a connection through the LTE module and access other functionalities via AT commands.

## LTE connection

To setup a connection you'll need to retrieve the **APN name** of the network provider of your SIM card.
Below we'll use `myapn` as an example.

### Option 1: NetworkManager and ModemManager

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

Use `mmcli` to get modem and SIM information:

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

### Option 2: libqmi and udhcpc

If you are not using NetworkManager/ModemManager to manage your connections, you can opt for this method.

**NB**: ModemManager must be not installed or disabled:

```
sudo systemctl stop ModemManager
sudo systemctl disable ModemManager
```

Install libqmi and udhcpc:

```
sudo apt update
sudo apt install libqmi-utils udhcpc
```

Set interface `wwan0` into `raw_ip` mode:

```
sudo ip link set wwan0 down
echo 'Y' | sudo tee /sys/class/net/wwan0/qmi/raw_ip
sudo ip link set wwan0 up
```

To establish a connection, repeat the following command (replace `myapn` with your APN name) until succesful:

```
sudo qmicli -d /dev/cdc-wdm0 --device-open-net='net-raw-ip|net-no-qos-header' --wds-start-network="apn=myapn,ip-type=4" --client-no-release-cid
```

When a connection is established the output will be similar to the following:

```
[/dev/cdc-wdm0] Network started
    Packet data handle: '1234567890'
[/dev/cdc-wdm0] Client ID not released:
    Service: 'wds'
        CID: '12'
```

Finally, assign a default IP address and route using `udhcpc`:

```
sudo udhcpc -q -f -i wwan0
```

To have the connection automatically setup at boot or whenever the `wwan0` goes up, use the following in `/etc/network/interfaces.d/wwan0` (replace `myapn` with your APN name):

```
auto wwan0
iface wwan0 inet manual
     pre-up ifconfig wwan0 down
     pre-up echo Y > /sys/class/net/wwan0/qmi/raw_ip
     pre-up for _ in $(seq 1 10); do /usr/bin/test -c /dev/cdc-wdm0 && break; /bin/sleep 1; done
     pre-up for _ in $(seq 1 10); do /usr/bin/qmicli -d /dev/cdc-wdm0 --device-open-net='net-raw-ip|net-no-qos-header' --wds-start-network="apn=myapn,ip-type=4" --client-no-release-cid && break; /bin/sleep 1; done
     pre-up udhcpc -i wwan0
     post-down /usr/bin/qmi-network /dev/cdc-wdm0 stop
```

### Test the connection

Use `ip` to check the status of `wwan0`:

```
$ ip addr show wwan0
5: wwan0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1420 qdisc pfifo_fast state UNKNOWN group default qlen 1000
    link/none 
    inet 10.45.1.174/30 brd 10.45.1.175 scope global noprefixroute wwan0
       valid_lft forever preferred_lft forever
```

Ping test:

```
ping -I wwan0 8.8.8.8
```

wget test (set `--bind-address=` to the broadcast `brd` address from the `ip` command above):

```
wget --bind-address=10.45.1.175 --output-document=/dev/null http://example.com
```

Bring down the connection:

```
sudo ifdown wwan0
```

Bring up the connection:

```
sudo ifup wwan0
```

## AT interface

By default, the Telit module exposes 5 usb-serial ports: `/dev/ttyUSB[0-4]`.

As enumeration can change when other ttyUSB devices are connected, add static paths to each port using the `udev` device manager.

For instance, create a file named `99-lte-usb.rules` in `/etc/udev/rules.d/` with the following content:

```
SUBSYSTEMS=="usb", KERNEL=="ttyUSB[0-9]*", \
ENV{ID_MODEL_ID}=="1060", ENV{ID_VENDOR_ID}=="1bc7", \
SYMLINK+="x2-lte-$attr{bInterfaceNumber}"
```

Reload the udev rules with:

```
sudo udevadm control --reload-rules && sudo udevadm trigger
```

The following device paths will become available:

```
/dev/x2-lte-00
/dev/x2-lte-03
/dev/x2-lte-04
/dev/x2-lte-05
/dev/x2-lte-06
```

The AT commands interface is available on `/dev/x2-lte-04`.

Refer to the documentation of the Telit LN920 module for details on available AT commands.

## GNSS

To configure GNSS support send the following commands to the AT interface.

Disable GNSS:

```
AT$GPSP=0
```

Select active mode for the Taoglas MA256.A.LBI.001 antenna:

```
AT$GPSANTPORT=3
```

Configure NMEA type, e.g.:

```
AT#LOCNMEATYPE=0,134020607
```

Enable GNSS:

```
AT$GPSP=1
```

The NMEA stream will be available on `/dev/x2-lte-03`.
