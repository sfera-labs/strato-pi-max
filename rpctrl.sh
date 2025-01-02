#!/bin/bash

# Utility for controlling the RP2040 on Strato Pi Max.
#
#    Copyright (C) 2023-2025 Sfera Labs S.r.l. - All rights reserved.
#
#    For information, visit https://www.sferalabs.cc
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# LICENSE.txt file for more details.

pinctrl > /dev/null 2>&1 || { shopt -s expand_aliases ; alias pinctrl="raspi-gpio" ;}

function _usage() {
        echo "Usage: $0 COMMAND"
        echo "Commands:"
        echo "    off         hold RP in reset state"
        echo "    on          let RP run"
        echo "    reset       RP reset and run"
        echo "    mount       reset RP in boot mode and mount to ./RP2040"
        echo "    load FILE   mount and copy FILE to ./RP2040"
}

function _off() {
    echo "switching off ..."
    sudo umount ./RP2040 2> /dev/null
    pinctrl set 20 op
    pinctrl set 20 dl
}

function _on() {
    echo "switching on ..."
    pinctrl set 20 ip
}

function _bootSelEnable() {
    pinctrl set 21 op
    pinctrl set 21 dl
}

function _bootSelRelease() {
    pinctrl set 21 ip
}

function _onBootMode() {
    echo "enabling boot mode ..."
    _bootSelEnable
    sleep 0.1
    _on
    sleep 0.1
    _bootSelRelease
}

if [ $# == 0 ]; then
    _usage
else
    case "$1" in
    off )
        _off
        ;;
    on )
        _on
        ;;
    reset )
        _off
        sleep 0.1
        _on
        ;;
    mount )
        if [ ! -d "./RP2040" ]; then
            mkdir ./RP2040
        fi
        _off
        sleep 0.5
        DEVS_PRE=$(ls -1 /dev/sd?1 2> /dev/null)
        _onBootMode
        echo "looking for disk ..."
        for i in {1..10}; do
            sleep 0.5
            DEVS_POST=$(ls -1 /dev/sd?1 2> /dev/null)
            DEVS="${DEVS_PRE}"$'\n'"${DEVS_POST}"
            DISK=$(sort <(cat <<< "$DEVS") | uniq -u | tr -d '\n')
            if [ ! -z "$DISK" ]; then
                echo "mounting $DISK to ./RP2040 ..."
                sudo mount $DISK ./RP2040 > /dev/null
                break
            fi
        done
        mountpoint -q ./RP2040 && echo "mounted"
        ls -l ./RP2040/INFO_UF2.TXT > /dev/null 2>&1 || { echo "error" ; exit 1 ;}
        ;;
    load )
        if [ -z "$2" ]; then
            echo "Error: missing FILE argument"
            exit 1
        fi
        $0 mount && sudo cp -v $2 ./RP2040 && sudo umount ./RP2040 && rm -r ./RP2040 && echo "$2 loaded"
        ;;
    * )
        _usage
        ;;
    esac
fi
