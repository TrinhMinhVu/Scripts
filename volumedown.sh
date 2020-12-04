#!/bin/sh
amixer --quiet sset Master 5%-
exec $HOME/Scripts/notify.sh audio-volume-medium $(amixer sget Master | awk -F"[][]" '/Left:/ { print $2 }')