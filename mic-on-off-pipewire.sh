#!/bin/bash

if [ "$(head .local/mic-on-off-pipewire)" == "ON" ]; then
	pactl set-source-mute alsa_input.pci-0000_00_1f.3.analog-stereo 1
	echo "OFF" > .local/mic-on-off-pipewire
	polybar-msg hook ipc-mic-on-off 1
	dunstify -h string:x-dunst-stack-tag:mute "Mic" "Off"
else
	pactl set-source-mute alsa_input.pci-0000_00_1f.3.analog-stereo 0
	echo "ON" > .local/mic-on-off-pipewire
	polybar-msg hook ipc-mic-on-off 1
	dunstify -h string:x-dunst-stack-tag:mute "Mic" "On"
fi


