#!/bin/bash
b=$(xbacklight -get)

if [ ${b%%.*} -gt 90 ]; then
	xbacklight -set 100%
else
	xbacklight -inc 10%
fi
c=$(xbacklight -get)
dunstify -h string:x-dunst-stack-tag:brightness "Brightness" "${c%.*}%"
