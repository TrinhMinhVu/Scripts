#!/bin/bash
all=$(pacman -Qe | cut -d " " -f 1)
echo -e "# $(date)\n$all\n\n" >> $HOME/GhiChu/OtherNotes/list-of-pacman-Qe
