#
# Copyright (C) 2013-2016 OpenWrt.org
# Copyright (C) 2017 Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_RELEASE:=1
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/HotRays/u-boot.git
PKG_SOURCE_DATE:=2018-04-19
PKG_SOURCE_VERSION:=017278105e24acbf5f53437d9edb8791e1623c07

PKG_VERSION:=2018.04.$(PKG_SOURCE_VERSION)

PKG_MAINTAINER:=Chen Minqiang <ptpt52@gmail.com>

include $(INCLUDE_DIR)/u-boot.mk
include $(INCLUDE_DIR)/package.mk

define U-Boot/Default
  BUILD_TARGET:=sunxi
  UBOOT_IMAGE:=u-boot-sunxi-with-spl.bin
  UENV:=default
  HIDDEN:=1
endef

define U-Boot/orangepi_oneplus
  BUILD_SUBTARGET:=cortexa53
  NAME:=Xunlong Orange Pi OnePlus
  BUILD_DEVICES:=sun50i-h6-orangepi-oneplus
  DEPENDS:=+PACKAGE_u-boot-orangepi_oneplus:arm-trusted-firmware-sunxi-h6
  UENV:=h64
endef

UBOOT_TARGETS := \
	orangepi_oneplus

UBOOT_CONFIGURE_VARS += USE_PRIVATE_LIBGCC=yes

UBOOT_MAKE_FLAGS += \
	BL31=$(STAGING_DIR_IMAGE)/bl31.bin

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
ifeq ($(SUBTARGET),cortexa53)
	cat $(PKG_BUILD_DIR)/spl/sunxi-spl.bin $(PKG_BUILD_DIR)/u-boot.itb > $(STAGING_DIR_IMAGE)/$(BUILD_DEVICES)-u-boot-with-spl.bin
else
	$(CP) $(PKG_BUILD_DIR)/$(UBOOT_IMAGE) $(STAGING_DIR_IMAGE)/$(BUILD_DEVICES)-u-boot-with-spl.bin
endif
	mkimage -C none -A arm -T script -d uEnv-$(UENV).txt \
		$(STAGING_DIR_IMAGE)/$(BUILD_DEVICES)-boot.scr
endef

define Package/u-boot/install/default
endef

$(eval $(call BuildPackage/U-Boot))
