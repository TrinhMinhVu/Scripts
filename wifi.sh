#!/bin/bash
wifiinterface="wlan0"

case $1 in
	"--scan")
		nmcli device wifi rescan && nmcli device wifi list
	;;
	"--list")
		nmcli -s c show
	;;
	"--disconnect")
		nmcli device disconnect $wifiinterface
	;;
	"--delete")
		nmcli c delete "$2"
	;;
	"--password")
		 nmcli -s -t c show "$2" | grep "wireless-security.psk" | awk -F"psk:" '{ print $2 }'
	;;
	"--connect")
		[ -n "$(nmcli -t c | grep "$2")" ] && nmcli con up "$2" || nmcli device wifi connect "$2" --ask
	;;
	"--help")
	echo -e "--scan to scan available wifi\n--list to list saved connections\n--connect <ssid> to connect\n--disconnect to disconnect all connections\n--password <ssid> to see a connection's password\n--delete <connection> to delete a known connection"
	;;
	*)
	echo -e "--scan to scan available wifi\n--list to list saved connections\n--connect <ssid> to connect\n--disconnect to disconnect all connections\n--password <ssid> to see a connection's password\n--delete <connection> to delete a known connection"
	
esac
exit 0