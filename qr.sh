#!/bin/sh
if [ -d "$HOME"/Pictures/qrs ];then
name=$(date +%dt%mn%Y-%T)
dmenu -l 0 -p "Text to encode?" | qrencode -s 3 -l L -o "$HOME/Pictures/qrs/$name.png" && feh -d -g 300x300 -Z --force-aliasing "$HOME"/Pictures/qrs/"$name.png"
else
mkdir "$HOME"/Pictures/qrs
name=$(date +%dt%mn%Y-%T)
dmenu -l 0 -p "Text to encode?" | qrencode -s 3 -l L -o "$HOME/Pictures/qrs/$name.png" && feh -d -g 300x300 -Z --force-aliasing "$HOME"/Pictures/qrs/"$name.png"
fi

