#!/bin/bash

if [[ -z $(pacmd list-modules | grep device=hw:Loopback,1,0) ]]; then
	pacmd load-module module-alsa-source device=hw:Loopback,1,0
	dunstify -h string:x-dunst-stack-tag:droidmic "Droid mic:" "🎙 on"
	echo "" > ${HOME}/.local/status-droid-mic-on-off
	polybar-msg hook ipc-droid-mic-on-off 1
else
	pacmd unload-module module-alsa-source
	dunstify -h string:x-dunst-stack-tag:droidmic "Droid mic:" "🎙off"
	echo "" > ${HOME}/.local/status-droid-mic-on-off
	polybar-msg hook ipc-droid-mic-on-off 1
fi
