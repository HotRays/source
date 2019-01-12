#!/bin/sh
append DRIVERS "mt7612e"

. /lib/wifi/ralink_common.sh

prepare_mt7612e() {
	prepare_ralink_wifi mt7612e
}

scan_mt7612e() {
	scan_ralink_wifi mt7612e mt76x2e
}

disable_mt7612e() {
	disable_ralink_wifi mt7612e mt76x2e
}

enable_mt7612e() {
	enable_ralink_wifi mt7612e mt76x2e
}

detect_mt7612e() {
#	detect_ralink_wifi mt7612e mt76x2e
	ssid=mt7612e-`ifconfig eth0 | grep HWaddr | cut -c 51- | sed 's/://g'`
	cd /sys/module/
	[ -d $module ] || return
	[ -e /etc/config/wireless ] && return
	 cat <<EOF
config wifi-device 'mt7612e'
	option type 'mt7612e'
	option vendor 'ralink'
	option band '5G'
	option autoch '2'
	option mcastphymode '4'
	option fragthres '2346'
	option vht_ldpc '0'
	option bw '2'
	option ht_autoba '1'
	option ht_txstream '2'
	option wifimode '14'
	option ht_gi '1'
	option beacon '100'
	option aregion '0'
	option max_amsdu '1'
	option ht_stbc '1'
	option txpreamble '1'
	option country 'CN'
	option ht_badec '0'
	option dtim '1'
	option vht_sgi '1'
	option ht_bsscoexist '0'
	option shortslot '1'
	option rtsthres '2347'
	option ht_amsdu '1'
	option vht_bw_sig '0'
	option pktaggre '1'
	option txbf '0'
	option txpower '100'
	option ht_rxstream '2'
	option vht_stbc '1'
	option ht_ldpc '0'
	option ht_rdg '1'
	option txburst '1'
	option ht_opmode '0'
	option mcastmcs '2'
	option igmpsnoop '1'
	option ieee80211h '1'
	option ht_distkip '1'
	option bgprotect '0'
	option radio '1'
	option channel '36'

config wifi-iface
	option device 'mt7612e'
	option ifname 'rai0'
	option network 'lan'
	option mode 'ap'
	option disabled '0'
	option hidden '0'
	option ssid $ssid
	option encryption 'none'

EOF

}


