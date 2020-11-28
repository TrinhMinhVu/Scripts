#!/bin/sh
echo "to scan: nmcli device wifi list" 
echo "to connect unknown: nmcli device wifi connect <\"SSID\"> --ask"
echo "to connect known: nmcli con up <\"SSID\">"
echo "to disconect: nmcli con down <\"SSID\">"
echo "for more: https://wiki.archlinux.org/index.php/NetworkManager"

