#
# Copyright (C) 2017 Chris Blake <chrisrblake93@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=leds-aw9523b
PKG_RELEASE:=1

PKG_MAINTAINER:=Chris Blake <chrisrblake93@gmail.com>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define KernelPackage/leds-aw9523b
  SUBMENU:=LED modules
  TITLE:= AWININC aw9523b LED support
  DEPENDS:= +kmod-i2c-core
  FILES:=$(PKG_BUILD_DIR)/aw9523b.ko
  AUTOLOAD:=$(call AutoLoad,41,aw9523b)
  KCONFIG:=
endef

define KernelPackage/leds-aw9523b/description
  Driver for the AWININC aw9523b LEDs & Reset Button.
endef

EXTRA_KCONFIG:= \
	CONFIG_LEDS_AW9523B=m

EXTRA_CFLAGS:= \
	$(patsubst CONFIG_%, -DCONFIG_%=1, $(patsubst %=m,%,$(filter %=m,$(EXTRA_KCONFIG)))) \
	$(patsubst CONFIG_%, -DCONFIG_%=1, $(patsubst %=y,%,$(filter %=y,$(EXTRA_KCONFIG)))) \

MAKE_OPTS:= \
	$(KERNEL_MAKE_FLAGS) \
	SUBDIRS="$(PKG_BUILD_DIR)" \
	EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
	$(EXTRA_KCONFIG)

define Build/Compile
	 $(MAKE) -C "$(LINUX_DIR)" \
		$(MAKE_OPTS) \
		modules
endef

$(eval $(call KernelPackage,leds-aw9523b))
