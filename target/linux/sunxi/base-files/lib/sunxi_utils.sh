#!/bin/sh

env_iface="eth0"
env_part="mmcblk2boot1"
env_dev_path="/dev/$env_part"
env_command="uboot-env -d $env_dev_path -o 0x0 -l 0x20000"

init_mac_random() {
	echo 0 > /sys/block/$env_part/force_ro
	$env_command get || {
		$env_command del -I
	}

	mac=`ip link show dev usb0 | grep ether | awk '{print $2}'`
	[ -z "$mac" ] && return

	$env_command set ${env_iface}_mac $mac
}

env_reset_hw_addr() {
	local mac

	[ -b $env_dev_path ] || return

    mac=`$env_command get ${env_iface}_mac 2>/dev/null | awk -F= '{print $2}'`

    [ -z "$mac" ] && {
		init_mac_random
		mac=`$env_command get ${env_iface}_mac 2>/dev/null | awk -F= '{print $2}'`
	}

	[ -z "$mac" ] || {
        ifconfig ${env_iface} hw ether $mac 2>/dev/null
    }
}