#!/bin/bash
b=$(xbacklight -get)

if [ ${b%%.*} -lt 10 ]; then
	xbacklight -set 1%
else
	xbacklight -dec 10%
fi
c=$(xbacklight -get)
dunstify -h string:x-dunst-stack-tag:brightness "Brightness" "${c%.*}%"
