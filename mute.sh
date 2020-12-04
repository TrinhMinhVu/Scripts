#!/bin/sh
previousNumber=65
com=unmute
case $com in 
	"mute")
   		volume="$(amixer sget Master | grep 'Left:' | awk -F'[][]' '{ print $2}')"
   		sed -i "2s/.*/previousNumber=${volume%?}/" ${HOME}/Scripts/mute.sh
   		sed -i "3s/.*/com=unmute/" ${HOME}/Scripts/mute.sh
   		amixer sset Master 0
		notify-send "muted" -t 1000
	;;
	"unmute")
   		amixer sset Master $previousNumber%
   		sed -i "3s/.*/com=mute/" ${HOME}/Scripts/mute.sh
		notify-send "unmuted" -t 1000
   	;;
esac
