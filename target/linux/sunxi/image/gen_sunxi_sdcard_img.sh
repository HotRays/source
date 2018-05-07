#!/usr/bin/env bash
#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

set -ex
[ $# -eq 6 ] || [ $# -eq 7 ] || {
    echo "SYNTAX: $0 <file> <bootfs image> <rootfs image> <bootfs size> <rootfs size> <u-boot image> <failsafe image>"
    exit 1
}

OUTPUT="$1"
BOOTFS="$2"
ROOTFS="$3"
BOOTFSSIZE="$4"
ROOTFSSIZE="$5"
UBOOT="$6"
FAILSAFE="$7"

head=4
sect=63

HPAD=
test -n "$FAILSAFE" && HPAD=$((1024*32))
set `ptgen -o $OUTPUT -h $head -s $sect ${HPAD:+-L $HPAD} -l 1024 -t c -p ${BOOTFSSIZE}M -t 83 -p ${ROOTFSSIZE}M`

FAILSAFEOFFSET=$((1024 * 1024 / 512))
BOOTOFFSET="$(($1 / 512))"
BOOTSIZE="$(($2 / 512))"
ROOTFSOFFSET="$(($3 / 512))"
ROOTFSSIZE="$(($4 / 512))"

dd bs=1024 if="$UBOOT" of="$OUTPUT" seek=8 conv=notrunc
test -n "$FAILSAFE" && dd bs=512 if="$FAILSAFE" of="$OUTPUT" seek="$FAILSAFEOFFSET" conv=notrunc
dd bs=512 if="$BOOTFS" of="$OUTPUT" seek="$BOOTOFFSET" conv=notrunc
dd bs=512 if="$ROOTFS" of="$OUTPUT" seek="$ROOTFSOFFSET" conv=notrunc
