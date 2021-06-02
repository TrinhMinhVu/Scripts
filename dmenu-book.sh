#!/bin/sh
ls ${HOME}/Documents/EBOOKS/Programming | dmenu -l 25 -i -p "Book to open" | xargs -r -I name zathura "${HOME}/Documents/EBOOKS/Programming/name"
