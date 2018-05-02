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
PKG_SOURCE_VERSION:=8aca96c51efa8897f07df9b594a55b2c496660b1

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

define U-Boot/tempe_h6v2
  BUILD_SUBTARGET:=cortexa53
  NAME:=TEMPE H6 V2
  BUILD_DEVICES:=sun50i-h6-tempe-h6v2
  DEPENDS:=+PACKAGE_u-boot-tempe-h6v2:arm-trusted-firmware-sunxi-h6
  UENV:=h64
endef

define U-Boot/tempe_lite2
  BUILD_SUBTARGET:=cortexa53
  NAME:=TEMPE Lite 2
  BUILD_DEVICES:=sun50i-h6-tempe-lite2
  DEPENDS:=+PACKAGE_u-boot-tempe-lite2:arm-trusted-firmware-sunxi-h6
  UENV:=h64
endef

define U-Boot/tempe_a55
  BUILD_SUBTARGET:=cortexa53
  NAME:=TEMPE A55
  BUILD_DEVICES:=sun50i-h6-tempe-a55
  DEPENDS:=+PACKAGE_u-boot-tempe-a55:arm-trusted-firmware-sunxi-h6
  UENV:=h64-a55
endef

UBOOT_TARGETS := \
	tempe_h6v2 \
	tempe_lite2 \
  tempe_a55

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
