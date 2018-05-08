#
# Copyright (C) 2013-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

define KernelPackage/rtc-sunxi
    SUBMENU:=$(OTHER_MENU)
    TITLE:=Sunxi SoC built-in RTC support
    DEPENDS:=@TARGET_sunxi
    $(call AddDepends/rtc)
    KCONFIG:= \
	CONFIG_RTC_DRV_SUNXI \
	CONFIG_RTC_CLASS=y
    FILES:=$(LINUX_DIR)/drivers/rtc/rtc-sunxi.ko
    AUTOLOAD:=$(call AutoLoad,50,rtc-sunxi)
endef

define KernelPackage/rtc-sunxi/description
 Support for the AllWinner sunXi SoC's onboard RTC
endef

$(eval $(call KernelPackage,rtc-sunxi))

define KernelPackage/sunxi-ir
    SUBMENU:=$(OTHER_MENU)
    TITLE:=Sunxi SoC built-in IR support (A20)
    DEPENDS:=@TARGET_sunxi +kmod-input-core
    $(call AddDepends/rtc)
    KCONFIG:= \
	CONFIG_MEDIA_SUPPORT=y \
	CONFIG_MEDIA_RC_SUPPORT=y \
	CONFIG_RC_DEVICES=y \
	CONFIG_IR_SUNXI
    FILES:=$(LINUX_DIR)/drivers/media/rc/sunxi-cir.ko
    AUTOLOAD:=$(call AutoLoad,50,sunxi-cir)
endef

define KernelPackage/sunxi-ir/description
 Support for the AllWinner sunXi SoC's onboard IR (A20)
endef

$(eval $(call KernelPackage,sunxi-ir))

define KernelPackage/ata-sunxi
    TITLE:=AllWinner sunXi AHCI SATA support
    SUBMENU:=$(BLOCK_MENU)
    DEPENDS:=@TARGET_sunxi +kmod-ata-ahci-platform +kmod-scsi-core
    KCONFIG:=CONFIG_AHCI_SUNXI
    FILES:=$(LINUX_DIR)/drivers/ata/ahci_sunxi.ko
    AUTOLOAD:=$(call AutoLoad,41,ahci_sunxi,1)
endef

define KernelPackage/ata-sunxi/description
 SATA support for the AllWinner sunXi SoC's onboard AHCI SATA
endef

$(eval $(call KernelPackage,ata-sunxi))

define KernelPackage/sun4i-emac
  SUBMENU:=$(NETWORK_DEVICES_MENU)
  TITLE:=AllWinner EMAC Ethernet support
  DEPENDS:=@TARGET_sunxi +kmod-of-mdio +kmod-libphy
  KCONFIG:=CONFIG_SUN4I_EMAC
  FILES:=$(LINUX_DIR)/drivers/net/ethernet/allwinner/sun4i-emac.ko
  AUTOLOAD:=$(call AutoProbe,sun4i-emac)
endef

$(eval $(call KernelPackage,sun4i-emac))

define KernelPackage/dwmac-sun8i
  SUBMENU:=$(NETWORK_DEVICES_MENU)
  TITLE:=SUN50I H6 EMAC Ethernet support
  DEPENDS:=@TARGET_sunxi +kmod-of-mdio +kmod-libphy +kmod-mdio
  KCONFIG:=CONFIG_DWMAC_SUN8I=m \
  CONFIG_MDIO_BUS_MUX \
  CONFIG_STMMAC_ETH \
  CONFIG_STMMAC_PLATFORM \
  CONFIG_DWMAC_DWC_QOS_ETH=n \
  CONFIG_DWMAC_GENERIC=n \
  CONFIG_DWMAC_SUNXI=n \
  CONFIG_MDIO_SUN4I=n
  FILES:=$(LINUX_DIR)/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.ko \
  $(LINUX_DIR)/drivers/net/phy/mdio-mux.ko \
  $(LINUX_DIR)/drivers/net/ethernet/stmicro/stmmac/stmmac-platform.ko \
  $(LINUX_DIR)/drivers/net/ethernet/stmicro/stmmac/stmmac.ko
  AUTOLOAD:=$(call AutoProbe,dwmac-sun8i)
endef

$(eval $(call KernelPackage,dwmac-sun8i))

define KernelPackage/sound-soc-sunxi
  TITLE:=AllWinner built-in SoC sound support
  KCONFIG:=CONFIG_SND_SUN4I_CODEC
  FILES:=$(LINUX_DIR)/sound/soc/sunxi/sun4i-codec.ko
  AUTOLOAD:=$(call AutoLoad,65,sun4i-codec)
  DEPENDS:=@TARGET_sunxi +kmod-sound-soc-core
  $(call AddDepends/sound)
endef

define KernelPackage/sound-soc-sunxi/description
  Kernel support for AllWinner built-in SoC audio
endef

$(eval $(call KernelPackage,sound-soc-sunxi))

define KernelPackage/GobiNet
  SUBMENU:=$(USB_MENU)
  TITLE:=QCOM GobiNet LTE/CDMA support
  DEPENDS:=@TARGET_sunxi:TARGET_sunxi_cortexa53_DEVICE_sun50i-h6-tempe-a55 +kmod-usb-net $(1)
  KCONFIG:=CONFIG_USB_NET_GOBINET=m
  FILES:=$(LINUX_DIR)/drivers/net/usb/GobiNet.ko
  AUTOLOAD:=$(call AutoProbe,GobiNet)
endef

$(eval $(call KernelPackage,GobiNet))