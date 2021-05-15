#!/bin/sh
# in audacious `song-change.sh %f %T %a`
path="$(echo "$1" | cut -c 8- - | sed 's/%20/\ /g')"
ffmpeg -y -i "$path" -filter:v scale=-1:50 -an ~/.local/song.png
[ -n "$3" ] && dunstify -h string:x-dunst-stack-tag:song-change -t 5000 -i ~/.local/song.png "Now Playing:" "<i>$2 \nBy artist: $3</i>"
