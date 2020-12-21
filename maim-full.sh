#!/bin/bash

maim -m 1 ${HOME}/Pictures/Screenshots/$(date +%dt%mn%Y-%s).png && nofity-send "taken"
exit 0