#!/bin/bash
ls ${HOME}/Scripts | rofi -dmenu -theme "~/.cache/wal/colors-rofi-dark.rasi" | xargs -r -I name xfce4-terminal -e "nvim ${HOME}/Scripts/name" &
