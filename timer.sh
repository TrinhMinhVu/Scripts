#!/bin/bash
time=$1
reason=$(echo $@ | awk '{$1="";print $0}')
dunstify -t 0 "timer:${reason} has started" "ETA: $time" &
# usage: timer.sh 3m "luoc trung"
sleep $1 && dunstify -t 0 "timer:${reason} is over" "${time} had passed" &
