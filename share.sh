#!/bin/bash
curl -F"file=@$(find $HOME -type f | rofi -dmenu -theme "~/.cache/wal/colors-rofi-dark.rasi" )" 0x0.st | xclip -selection c
dunstify "file uploaded, link copied"
