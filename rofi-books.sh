#!/bin/sh
ls ${HOME}/Documents/EBOOKS/Programming | rofi -dmenu -p "Book to open" | xargs -r -I name zathura "${HOME}/Documents/EBOOKS/name"
