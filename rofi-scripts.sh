#!/bin/bash
ls ${HOME}/Scripts | rofi -dmenu -p "Script to edit" | xargs -r -I name xfce4-terminal -e "nvim ${HOME}/Scripts/name" &
