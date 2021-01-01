#!/bin/sh
com=unmute
case $com in
	"mute")
		pacmd set-card-profile alsa_card.pci-0000_00_1f.3 output:analog-stereo
		sed -i "2s/.*/com=unmute/" ${HOME}/Scripts/mic-on-off.sh
		echo "🎤 off" > ${HOME}/.local/status-mic-on-off
		polybar-msg hook ipc-mic-on-off 1
		#notify-send "mic muted" -t 1000
	;;
	"unmute")
		pacmd set-card-profile alsa_card.pci-0000_00_1f.3 output:analog-stereo+input:analog-stereo
		sed -i "2s/.*/com=mute/" ${HOME}/Scripts/mic-on-off.sh
		echo "🎤 on" > ${HOME}/.local/status-mic-on-off
		polybar-msg hook ipc-mic-on-off 1
		#notify-send "mic umuted" -t 1000
	;;
esac
exit 0
