#!/bin/sh
pactl set-sink-mute alsa_output.pci-0000_00_1f.3.analog-stereo toggle
com=mute
   case $com in
      "mute")
         notify-send "muted" -t 1000
         sed -i "3s/.*/com=unmute/" ${HOME}/Scripts/mute.sh
      ;;
      "unmute")
         notify-send "unmuted" -t 1000
         sed -i "3s/.*/com=mute/" ${HOME}/Scripts/mute.sh
      ;;
   esac
exit 0
#previousNumber=60
#com=mute
#case $com in 
#	"mute")
#   		volume="$(amixer sget Master | awk -F"[][]" '/Left:/ { print $2 }')"
# 		   sed -i "2s/.*/previousNumber=${volume%?}/" ${HOME}/Scripts/mute.sh
#   		sed -i "3s/.*/com=unmute/" ${HOME}/Scripts/mute.sh
#   		amixer sset Master 0
#		   notify-send "muted" -t 1000
#	;;
#	"unmute")
#  		amixer sset Master $previousNumber%
#   		sed -i "3s/.*/com=mute/" ${HOME}/Scripts/mute.sh
#		   notify-send "unmuted" -t 1000
#   ;;
#esac
