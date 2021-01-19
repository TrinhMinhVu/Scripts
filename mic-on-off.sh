#!/bin/sh
com=unmute
case $com in
	"mute")
		pacmd set-card-profile alsa_card.pci-0000_00_1f.3 output:analog-stereo
		sed -i "2s/.*/com=unmute/" ${HOME}/Scripts/mic-on-off.sh
		echo "🎤 off" > ${HOME}/.local/status-mic-on-off
		polybar-msg hook ipc-mic-on-off 1
		amixer -c PCH sset 'Front Mic' mute 0%
		amixer -c PCH sset 'Front Mic Boost' 0%
		dunstify -h string:x-dunst-stack-tag:mute "🎤 front mic off"
	;;
	"unmute")
		pacmd set-card-profile alsa_card.pci-0000_00_1f.3 output:analog-stereo+input:analog-stereo
		sed -i "2s/.*/com=mute/" ${HOME}/Scripts/mic-on-off.sh
		echo "🎤 on" > ${HOME}/.local/status-mic-on-off
		polybar-msg hook ipc-mic-on-off 1
		amixer -c PCH sset 'Front Mic' unmute 100%
		amixer -c PCH sset 'Front Mic Boost' 22%
		dunstify -h string:x-dunst-stack-tag:mute "🎤 front mic on"
	;;
esac
exit 0
