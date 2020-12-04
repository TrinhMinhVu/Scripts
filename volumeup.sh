#!/bin/sh
amixer --quiet sset Master 5%+ 
exec $HOME/Scripts/notify.sh audio-volume-high $(amixer sget Master | awk -F"[][]" '/Left:/ { print $2 }')
