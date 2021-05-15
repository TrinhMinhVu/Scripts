#!/bin/sh
amixer --quiet sset Master 5%+
#exec $HOME/Scripts/notify.sh audio-volume-high $(amixer sget Master | awk -F"[][]" '/Left:/ { print $2 }')
#exec $HOME/Scripts/notify.sh audio-volume-high $(pacmd dump-volumes | awk '{print $8; exit}')
dunstify -h string:x-dunst-stack-tag:volume "Volume:" "$(head ${HOME}/.local/status-head-line) $(pacmd dump-volumes | awk '{print $8; exit}')"
exit 0
