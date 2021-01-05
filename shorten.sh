#!/bin/bash
link=$(rofi -dmenu -theme "~/.cache/wal/colors-rofi-dark.rasi")
dunstify "shorten $link"
curl -F"shorten=$link" http://0x0.st | xclip -selection c
