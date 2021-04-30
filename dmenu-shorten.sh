#!/bin/bash
link=$(dmenu -p "Link to shorten")
if [ -n "$link" ]; then
	if [ -z "$(echo "$link" | grep "http" -)" ]; then
		shorten=curl -F"shorten=https://$link" http://0x0.st | xclip -selection c
		dunstify -t 5000 "Shorten $link" "as $shorten, copied to clipboard"
	else
		curl -F"shorten=$link" http://0x0.st | xclip -selection c
		dunstify -t 5000 "Shorten $link" "as $shorten, copied to clipboard"
	fi
else
	dunstify "No link specify or link must have http prefix"
fi
#curl -F"shorten=$link" http://0x0.st | xclip -selection c

