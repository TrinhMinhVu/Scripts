#!/bin/bash
link=$(rofi -dmenu -l 0)
dunstify "shorten $link"
curl -F"shorten=$link" http://0x0.st | xclip -selection c

