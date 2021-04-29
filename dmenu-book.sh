#!/bin/sh
ls ${HOME}/Documents/EBOOKS/Programming | dmenu -i -p "Book to open" | xargs -r -I name zathura "${HOME}/Documents/EBOOKS/name"
