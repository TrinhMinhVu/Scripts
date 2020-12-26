#!/bin/bash
current=0;

case $current in
	0)
	sudo protonvpn c -f -p UDP
    sed -i "2s/.*/current=1;/" "${HOME}"/Scripts/switch-vpn.sh
    echo "🙈 on" > ${HOME}/.local/vpn
	polybar-msg hook vpn 1
	notify-send -t 2000 "connected"
   	;;
	*)
	sudo protonvpn d
    sed -i "2s/.*/current=0;/" "${HOME}"/Scripts/switch-vpn.sh
    echo "🐵 off" > ${HOME}/.local/vpn
	polybar-msg hook vpn 1
	notify-send -t 2000 "disconnected"
	;;
esac
exit 0