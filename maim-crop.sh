#!/bin/sh
maim -m 1 -s ${HOME}/Pictures/Screenshots/$(date +%dt%mn%Y-%s).png && nofity-send "taken"
exit 0