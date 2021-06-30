#!/bin/sh
name=$(ls ${HOME}/Documents/EBOOKS/Programming | dmenu -l 25 -i -p "Book to open")
echo "$name" > ~/.local/last-read-book
zathura "${HOME}/Documents/EBOOKS/Programming/$name"
