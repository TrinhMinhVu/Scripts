#!/bin/bash
line=13

theme=$(sed -n "$line"p ~/wal-themes)

if [[ "$1" = "next" ]]; then
newline=$(($line+1))
fi

if [[ "$1" = "prev" ]]; then
newline=$(($line-1))
fi

wal --theme $theme
sed -i "2s/.*/line=$newline/" ~/Scripts/wal-changer.sh

