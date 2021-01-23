#!/bin/bash
bsp-layout cycle --layouts tall,tiled,wide
dunstify -h string:x-dunst-stack-tag:layout "$(bsp-layout get $(bspc query -D -d focused --names))"
