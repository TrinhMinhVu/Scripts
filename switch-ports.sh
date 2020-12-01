#!/bin/sh
current=1;

case $current in
	0)
		pacmd set-sink-port alsa_output.pci-0000_00_1f.3.analog-stereo analog-output-headphones
    		amixer -c 0 sset Front 0
    #amixer chon card hda intel pcm set cai front ve 0, front khong phai 0 thi loa cung phat nhac riperino
       		sed -i "2s/.*/current=1;/" "${HOME}"/Scripts/switch-ports.sh
    		#echo "headphone" > ${HOME}/Scripts/status-head-line
		notify-send "headphone" -t 1000
   	;;
	*)
    		pacmd set-sink-port alsa_output.pci-0000_00_1f.3.analog-stereo analog-output-lineout
    		sed -i "2s/.*/current=0;/" "${HOME}"/Scripts/switch-ports.sh
    		#echo "lineout" > ${HOME}/Scripts/status-head-line
		notify-send "lineout" -t 1000
	;;
esac
