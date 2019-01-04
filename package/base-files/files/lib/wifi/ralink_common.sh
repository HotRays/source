# this file will be included in
#     /lib/wifi/mt{chipname}.sh

MAX_STA_NUM=7
repair_wireless_uci() {
    echo "repair_wireless_uci" >>/tmp/wifi.log
    vifs=`uci show wireless | grep "=wifi-iface" | sed -n "s/=wifi-iface//gp"`
    echo $vifs >>/tmp/wifi.log

    ifn5g=0
    ifclin5g=0
    ifn2g=0
    ifclin2g=0
    for vif in $vifs; do
        local netif nettype device netif_new
        echo  "<<<<<<<<<<<<<<<<<" >>/tmp/wifi.log
        netif=`uci -q get ${vif}.ifname`
        nettype=`uci -q get ${vif}.network`
        device=`uci -q get ${vif}.device`
        mode=`uci -q get ${vif}.mode`
        echo mode:$mode >> /tmp/wifi.log
        if [ "$device" == "" ]; then
            echo "device cannot be empty!!" >>/tmp/wifi.log
            continue
        fi
        echo "device name $device!!" >>/tmp/wifi.log
        echo "netif $netif" >>/tmp/wifi.log
        echo "nettype $nettype" >>/tmp/wifi.log

        case "$device" in
            mt7620 | mt7602e | mt7603e | mt7628 | mt7688 | mt7615e2)
                [ $ifn2g -gt $MAX_STA_NUM ] && {
                    uci delete $vif
                    continue
                }
                if [ "$mode" == "sta" ]; then
                    netif_new="apcli"${ifclin2g}
                    ifclin2g=$(( $ifclin2g + 1 ))
                else
                    netif_new="ra"${ifn2g}
                    ifn2g=$(( $ifn2g + 1 ))
                fi
            ;;
            mt7610e | mt7612e | mt7615e5)
		[ $ifn5g -gt $MAX_STA_NUM ] && {
                    uci delete $vif
                    continue
                }
                if [ "$mode" == "sta" ]; then
                    netif_new="apclii"${ifclin5g}
                    ifclin5g=$(( $ifclin5g + 1 ))
                else
                    netif_new="rai"${ifn5g}
                    ifn5g=$(( $ifn5g + 1 ))
                fi
                ;;
            * )
                echo "device $device not recognized!! " >>/tmp/wifi.log
                ;;
        esac

        echo "ifn5g = ${ifn5g}, ifn2g = ${ifn2g}" >>/tmp/wifi.log
        echo "netif_new = ${netif_new}" >>/tmp/wifi.log

        #if [ "$netif" == "" ]; then
        echo "ifname set to ${netif_new}" >>/tmp/wifi.log
        uci -q set ${vif}.ifname=${netif_new}
        #fi
        if [ "$nettype" == "" ]; then
            nettype="lan"
            echo "nettype empty, we'll fix it with ${nettype}" >>/tmp/wifi.log
            uci -q set ${vif}.network=${nettype}
        fi
        echo  ">>>>>>>>>>>>>>>>>" >>/tmp/wifi.log
    done
    uci changes 2>/dev/null >>/tmp/wifi.log
    uci commit 2>/dev/null
}


sync_uci_with_dat() {
    echo "sync_uci_with_dat($1,$2,$3,$4)" >>/tmp/wifi.log
    local device="$1"
    local datpath="$2"
    uci2dat -d $device -f $datpath >> /tmp/uci2dat.log
}



chk8021x() {
        local x8021x="0" encryption device="$1" prefix
        #vifs=`uci show wireless | grep "=wifi-iface" | sed -n "s/=wifi-iface//gp"`
        echo "u8021x dev $device" > /tmp/802.$device.log
        config_get vifs "$device" vifs
        for vif in $vifs; do
                local ifname
                config_get ifname $vif ifname
                echo "ifname = $ifname" >> /tmp/802.$device.log
                config_get encryption $vif encryption
                echo "enc = $encryption" >> /tmp/802.$device.log
                case "$encryption" in
                        wpa+*)
                                [ "$x8021x" == "0" ] && x8021x=1
                                echo 111 >> /tmp/802.$device.log
                                ;;
                        wpa2+*)
                                [ "$x8021x" == "0" ] && x8021x=1
                                echo 1l2 >> /tmp/802.$device.log
                                ;;
                        wpa-mixed*)
                                [ "$x8021x" == "0" ] && x8021x=1
                                echo 1l3 >> /tmp/802.$device.log
                                ;;
                esac
                ifpre=$(echo $ifname | cut -c1-3)
                echo "prefix = $ifpre" >> /tmp/802.$device.log
                if [ "$ifpre" == "rai" ]; then
                    prefix="rai"
                else
                    prefix="ra"
                fi
                if [ "1" == "$x8021x" ]; then
                    break
                fi
        done
        echo "x8021x $x8021x, pre $prefix" >>/tmp/802.$device.log
        if [ "1" == $x8021x ]; then
            pidof 8021xdi
            [ $? -eq 0 ] && {
                if [ "$prefix" == "ra" ]; then
                    echo "killall 8021xd" >>/tmp/802.$device.log
                    killall 8021xd 2>/dev/null 
                    echo "/bin/8021xd -d 9" >>/tmp/802.$device.log
                    8021xd -d 9 >> /tmp/802.$device.log 2>&1
                else # $prefixa == rai
                    echo "killall 8021xdi" >>/tmp/802.$device.log
                    killall 8021xdi 2>/dev/null 
                    echo "/bin/8021xdi -d 9" >>/tmp/802.$device.log
                    8021xdi -d 9 >> /tmp/802.$device.log 2>&1
                fi
            }
        else
            pidof 8021xdi
            [ $? -eq 0 ] && {
                if [ "$prefix" == "ra" ]; then
                    echo "killall 8021xd" >>/tmp/802.$device.log
                    killall 8021xd 2>/dev/null 
                else # $prefixa == rai
                    echo "killall 8021xdi" >>/tmp/802.$device.log
                    killall 8021xdi 2>/dev/null 
                fi
            }
        fi
}


prepare_ralink_wifi() {
    echo "prepare_ralink_wifi($1,$2,$3,$4)" >>/tmp/wifi.log
    local device=$1
    config_get channel $device channel
    config_get ssid $2 ssid
    config_get mode $device mode
    config_get ht $device ht
    config_get country $device country
    config_get regdom $device regdom

    # HT40 mode can be enabled only in bgn (mode = 9), gn (mode = 7)
    # or n (mode = 6).
    HT=0
    [ "$mode" = 6 -o "$mode" = 7 -o "$mode" = 9 ] && [ "$ht" != "20" ] && HT=1

    # In HT40 mode, a second channel is used. If EXTCHA=0, the extra
    # channel is $channel + 4. If EXTCHA=1, the extra channel is
    # $channel - 4. If the channel is fixed to 1-4, we'll have to
    # use + 4, otherwise we can just use - 4.
    EXTCHA=0
    [ "$channel" != auto ] && [ "$channel" -lt "5" ] && EXTCHA=1

}

scan_ralink_wifi() {
    local device="$1"
    local module="$2"
    echo "scan_ralink_wifi($1,$2,$3,$4)" >>/tmp/wifi.log
    repair_wireless_uci
    sync_uci_with_dat $device /etc/wireless/$device/$device.dat
}

disable_ralink_wifi() {
    local device="$1"
    local module="$2" 
    local ifnames=""
    echo "disable_ralink_wifi($1,$2,$3,$4)" >>/tmp/wifi.log

    case "$device" in
        mt7620 | mt7602e | mt7603e | mt7628 | mt7688 | mt7615e2)
	    ifnames=$(iwinfo | grep ESSID: | grep -v -E "apclii|rai" | awk '{print $1}')
	;;
	mt7610e | mt7612e | mt7615e5)
	    ifnames=$(iwinfo | grep ESSID: | grep -E "apclii|rai" | awk '{print $1}')
	;;
	*)
	    echo "$device is not support for disabled wisi" >>/tmp/wifi.log
	    return
	;;
    esac
    
    echo "vifs to down:$vifs" >> /tmp/wifi.log
    for ifname in $ifnames; do
	echo "ifconfig $ifname down" >>/tmp/wifi.log
        ifconfig $ifname down 2>/dev/null 
    done
    # kill any running ap_clients
    killall ap_client  2>/dev/null 
    sleep 1

    # in some case we have to reload drivers. (mbssid)
    ref=`cat /sys/module/$module/refcnt`
    if [ $ref != "0" ]; then
        # but for single driver, we only need to reload once.
        echo "$module ref=$ref, skip reload module" >>/tmp/wifi.log
    else
        echo "rmmod $module" >>/tmp/wifi.log
        rmmod $module
    fi
}

enable_ralink_wifi() {
    echo "enable_ralink_wifi($1,$2,$3,$4)" >>/tmp/wifi.log
    local device="$1"
    local module="$2"
    local cli_ifname=""
    config_get vifs "$device" vifs

    # shut down all vifs first
    for vif in $vifs; do
        config_get ifname $vif ifname
        ifconfig $ifname down 2>/dev/null 
    done

    # in some case we have to reload drivers. (mbssid)
    ref=`cat /sys/module/$module/refcnt`
    if [ $ref != "0" ]; then
        # but for single driver, we only need to reload once.
        echo "$module ref=$ref, skip reload module" >>/tmp/wifi.log
    else
        echo "insmod $module" >>/tmp/wifi.log
        insmod $module
    fi

    # bring up vifs
    for vif in $vifs; do
        config_get ifname $vif ifname
        config_get disabled $vif disabled
        config_get radio $device radio
        config_get mode $vif mode

        # here's the tricky part. we need at least 1 vif to trigger
        # the creation of all other vifs.
        ifconfig $ifname up
        echo "ifconfig $ifname up" >> /tmp/wifi.log
        if [ "$disabled" == "1" ]; then
            echo "$ifname sets to disabled." >> /tmp/wifi.log
            ifconfig $ifname down 2>/dev/null 
            return
        fi
        #Radio On/Off only support iwpriv command but dat file
        [ "$radio" == "0" ] && iwpriv $ifname set RadioOn=0
        local net_cfg bridge
        net_cfg="$(find_net_config "$vif")"
        [ -z "$net_cfg" ] || {
            bridge="$(bridge_interface "$net_cfg")"
            config_set "$vif" bridge "$bridge"
            start_net "$ifname" "$net_cfg"
            echo start_net "$ifname" "$net_cfg" >> /tmp/wifi.log
        }

        if [ "$mode" == "sta" ]; then
           iwpriv $ifname set ApCliAutoConnect=1 
        fi
        set_wifi_up "$vif" "$ifname"
    done

    chk8021x $device
    setsmp.sh
}

detect_ralink_wifi() {
    echo "detect_ralink_wifi($1,$2,$3,$4)" >>/tmp/wifi.log
    local channel
    local device="$1"
    local module="$2"
    local band
    local ifname
    cd /sys/module/
    [ -d $module ] || return
    config_get channel $device channel
    [ -z "$channel" ] || return
    case "$device" in
        mt7620 | mt7602e | mt7603e | mt7628 | mt7615e2)
            ifname="ra0"
            band="2.4G"
            ;;
        mt7610e | mt7612e | mt7615e5)
            ifname="rai0"
            band="5G"
            ;;
        * )
            echo "device $device not recognized!! " >>/tmp/wifi.log
            ;;
    esac
    cat <<EOF
config wifi-device    $device
    option type     $device
    option vendor   ralink
    option band     $band
    option channel  0
    option autoch   2

config wifi-iface
    option device   $device
    option ifname    $ifname
    option network  lan
    option mode     ap
    option ssid OpenWrt-$device
    option encryption psk2
    option key      12345678

EOF
}
