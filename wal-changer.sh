#!/bin/bash
line=148

theme=$(sed -n "$line"p ~/bruh)
wal --theme $theme
newline=$(($line+1))
sed -i "2s/.*/line=$newline/" ~/Scripts/wal-changer.sh
