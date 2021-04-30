#!/bin/bash
file=$(echo "" | dmenu -p "Path of file to upload")
if [ -f "$file" ]; then
	dunstify " Uploading" "$file"
	curl -F"file=@$file" 0x0.st | xclip -selection c
	dunstify " $file" "uploaded, link copied"
else
	dunstify -t 4000 "That was not a file lol" "Are you dumb?"
	exit 1;
fi
