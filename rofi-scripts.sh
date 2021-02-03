#!/bin/bash
ls ${HOME}/Scripts | rofi -dmenu | xargs -r -I name xfce4-terminal -e "nvim ${HOME}/Scripts/name" &
