#!/bin/sh
com=mute
case $com in
      "mute")
	 pactl set-sink-mute alsa_output.pci-0000_00_1f.3.analog-stereo 1
         notify-send "Audio:" "muted" -t 1000
         sed -i "2s/.*/com=unmute/" ${HOME}/Scripts/mute.sh
      ;;
      "unmute")
          pactl set-sink-mute alsa_output.pci-0000_00_1f.3.analog-stereo 0
	  dunstify "Audio:" "unmuted" -t 1000
         sed -i "2s/.*/com=mute/" ${HOME}/Scripts/mute.sh
      ;;
   esac
exit 0

