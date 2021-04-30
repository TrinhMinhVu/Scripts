#!/bin/bash
ls ${HOME}/Scripts | dmenu -l 25 -i -p "Script to edit" | xargs -r -I name xfce4-terminal -e "nvim ${HOME}/Scripts/name" &
