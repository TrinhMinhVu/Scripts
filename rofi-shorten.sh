#!/bin/bash
link=$(rofi -dmenu -l 0 -p "Link to shorten")
if [ -n "$link" ] && [ -n "$(echo "$link" | grep "http" -)" ]; then
	curl -F"shorten=$link" http://0x0.st | xclip -selection c 
	dunstify "shorten $link"
else
	dunstify "no link specify or link must have http prefix"
fi
#curl -F"shorten=$link" http://0x0.st | xclip -selection c

