#!/bin/bash

# Quickly create and activate a WiFi hotspot - optionally defining SSID and password - and deactivate it again when you don't need it anymore.

usage() {
  echo "Usage: $(basename $0) ssid passphrase"
  echo "       $(basename $0) down"
  echo "       $(basename $0)"
  exit 1
}

activate() {
  # If the connection "quick-hotspot" doesn't already exist...
  if ! nmcli connection show | grep quick-hotspot; then
    # ... then create it.
    nmcli connection add type wifi ifname '*' con-name quick-hotspot autoconnect no ssid "$ssid"
  else
    # ... else change the SSID of the existing connection.
    nmcli connection modify quick-hotspot ssid "$ssid"
  fi
  # Make the connection an access point
  nmcli connection modify quick-hotspot 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared
  # Change the password
  nmcli connection modify quick-hotspot 802-11-wireless-security.key-mgmt wpa-psk 802-11-wireless-security.psk "$pw"
  # Enable the connection
  nmcli connection up quick-hotspot
}

case $# in
  0)
    ssid=$(</dev/urandom tr -dc '12345!@#$%qwertQWERTasdfgASDFGzxcvbZXCVB' | head -c16; echo "")
    echo "SSID: $ssid"
    pw=$(shuf -i 10000000-99999999 -n 1) 
    echo "PW: $pw"
    activate
    ;;
  1)
    if [ $1 == down ]; then
      nmcli connection down "quick-hotspot"
      exit 0
    else usage
    fi
    ;;
  2)
    ssid="$1"
    if ! [ ${#2} -ge 8 ]; then
      echo "$(basename $0): Password needs to be 8 characters or longer."
      exit 1
    else
      pw="$2"
      activate
    fi
    ;;
  *)
    usage
    ;;
esac