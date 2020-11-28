#!/bin/sh
amixer --quiet sset Master 5%- && [ $(amixer sget Master | awk -F"[][]" '/Left:/ { print $2 }' | sed 's/.$//') -eq 0 ] && notify-send "0" -t 1000
#&& notify-send $(awk -F"[][]" '/Left:/ { print $2 }' <(amixer sget Master)) -t 1000
