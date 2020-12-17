#!/bin/bash
awk '/^[a-z]/ && last {print $0,"\t",last} {last=""} /^#/{last=$0}' ~/.config/sxhkd/sxhkdrc | column -t -s $'\t' | rofi -dmenu -theme "~/.cache/wal/colors-rofi-dark.rasi"