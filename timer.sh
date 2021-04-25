#!/bin/bash
time=$1
reason=$(echo $@ | awk '{$1="";print $0}')
dunstify -t 0 "Timer:${reason}; has started" "ETA: $time" &
# usage: timer.sh 3m "luoc trung"
sleep $1 && dunstify -u critical -t 0 "Timer:${reason}; is over" "${time} had passed" &
