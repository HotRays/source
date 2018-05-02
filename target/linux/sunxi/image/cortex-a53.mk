#
# Copyright (C) 2013-2016 OpenWrt.org
# Copyright (C) 2016 Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
ifeq ($(SUBTARGET),cortexa53)

define Device/sun50i-h5-nanopi-neo-plus2
  DEVICE_TITLE:=Nanopi NEO Plus2 (H5)
  SUPPORTED_DEVICES:=nanopi-neo-plus2
  SUNXI_DTS:=allwinner/sun50i-h5-nanopi-neo-plus2
  KERNEL_NAME := Image
  KERNEL := kernel-bin
endef

TARGET_DEVICES += sun50i-h5-nanopi-neo-plus2

define Device/sun50i-a64-pine64-plus
  DEVICE_TITLE:=Pine64 Plus A64
  SUPPORTED_DEVICES:=pine64,pine64-plus
  SUNXI_DTS:=allwinner/sun50i-a64-pine64-plus
  KERNEL_NAME := Image
  KERNEL := kernel-bin
endef

TARGET_DEVICES += sun50i-a64-pine64-plus

define Device/sun50i-a64-sopine-baseboard
  DEVICE_TITLE:=Pine64 Sopine
  SUPPORTED_DEVICES:=pine64,sopine-baseboard
  SUNXI_DTS:=allwinner/sun50i-a64-sopine-baseboard
  KERNEL_NAME := Image
  KERNEL := kernel-bin
endef

TARGET_DEVICES += sun50i-a64-sopine-baseboard


define Device/sun50i-h5-orangepi-zero-plus
  DEVICE_TITLE:=Xunlong Orange Pi Zero Plus
  SUPPORTED_DEVICES:=xunlong,orangepi-zero-plus
  SUNXI_DTS:=allwinner/sun50i-h5-orangepi-zero-plus
  KERNEL_NAME := Image
  KERNEL := kernel-bin
endef

TARGET_DEVICES += sun50i-h5-orangepi-zero-plus

define Device/sun50i-h6-tempe-h6v2
  DEVICE_TITLE:=Tempe H6 V2
  SUPPORTED_DEVICES:=tempe,tempe-h6v2
  SUNXI_DTS:=allwinner/sun50i-h6-tempe-h6v2
  KERNEL_NAME := Image
  KERNEL := kernel-bin
  DEVICE_PACKAGES := blockd kmod-fs-ext4 mkf2fs e2fsprogs fdisk partx-utils
endef

TARGET_DEVICES += sun50i-h6-tempe-h6v2

define Device/sun50i-h6-tempe-lite2
  DEVICE_TITLE:=TEMPE Lite 2
  SUPPORTED_DEVICES:=tempe,tempe-lite2
  SUNXI_DTS:=allwinner/sun50i-h6-tempe-lite2
  KERNEL_NAME := Image
  KERNEL := kernel-bin
  DEVICE_PACKAGES := blockd kmod-fs-ext4 mkf2fs e2fsprogs fdisk partx-utils kmod-brcmfmac
endef

TARGET_DEVICES += sun50i-h6-tempe-lite2

define Device/sun50i-h6-tempe-a55
  DEVICE_TITLE:=TEMPE A55
  SUPPORTED_DEVICES:=tempe,tempe-a55
  SUNXI_DTS:=allwinner/sun50i-h6-tempe-a55
  KERNEL_NAME := Image
  KERNEL := kernel-bin
  DEVICE_PACKAGES := blockd kmod-fs-ext4 mkf2fs e2fsprogs fdisk partx-utils kmod-brcmfmac
endef

TARGET_DEVICES += sun50i-h6-tempe-a55

endif
