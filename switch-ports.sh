#!/bin/sh
current=1;

case $current in
	0)
	pacmd set-sink-port alsa_output.pci-0000_00_1f.3.analog-stereo analog-output-headphones
	pacmd set-card-profile alsa_card.platform-snd_aloop.0 off
	amixer -c PCH sset Front 0
	#amixer chon card hda intel pcm set cai front ve 0, front khong phai 0 thi loa cung phat nhac riperino
	sed -i "2s/.*/current=1;/" "${HOME}"/Scripts/switch-ports.sh
	echo "" > ${HOME}/.local/status-head-line
	dunstify -h string:x-dunst-stack-tag:ports " headphone is up"
	polybar-msg hook ipc-head-line 1
	#exec ${HOME}/Scripts/notify.sh "headphone" -t 1000
   	;;
	*)
    	pacmd set-sink-port alsa_output.pci-0000_00_1f.3.analog-stereo analog-output-lineout
    	sed -i "2s/.*/current=0;/" "${HOME}"/Scripts/switch-ports.sh
    	echo "" > ${HOME}/.local/status-head-line
	dunstify -h string:x-dunst-stack-tag:ports " lineout is up"
	polybar-msg hook ipc-head-line 1
    	#notify-send "lineout" -t 1000
	;;
esac
exit 0
