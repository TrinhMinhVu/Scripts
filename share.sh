#!/bin/bash
file=$(find $HOME -type f | rofi -dmenu -p "File to upload")
dunstify " Uploading" "$file"
curl -F"file=@$file" 0x0.st | xclip -selection c
dunstify " $file" "uploaded, link copied"
