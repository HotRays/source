#
# Copyright (C) 2008-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=pwm-gpio
PKG_RELEASE:=2
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define KernelPackage/pwm-gpio
  SUBMENU:=Other modules
  TITLE:=General GPIO-PWM driver
  FILES:=$(PKG_BUILD_DIR)/pwm-gpio.ko
  AUTOLOAD:=$(call AutoLoad,33,pwm-gpio)
  KCONFIG:=
endef

define KernelPackage/pwm-gpio/description
 This is a replacement for the following in-kernel drivers:
 1) gpio_pwm (PWM_GPIO)
endef

MAKE_OPTS:= \
	$(KERNEL_MAKE_FLAGS) \
	SUBDIRS="$(PKG_BUILD_DIR)"

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
		$(MAKE_OPTS) \
		modules
endef

$(eval $(call KernelPackage,pwm-gpio))
