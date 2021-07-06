#!/bin/bash
battery_print() {
    bat=$(acpi | awk 'NR==1{print "I="$4 $3 substr($5, 1, 5)} NR==2{print " E="$4 $3 substr($5, 1, 5)}' ORS="" | sed -e 's/,//g' -e 's/Discharging/-/g' -e 's/Unknown//g' -e 's/Charging/+/g')
    echo $bat

    bat_0=$(cat /sys/class/power_supply/BAT0/capacity)
    bat_1=$(cat /sys/class/power_supply/BAT1/capacity)
    ac=$(cat /sys/class/power_supply/AC/online)

    if [ $((bat_0+bat_1)) -lt 20 ] && [ $ac -eq 0 ]; then
        dunstify -u critical -t 0 "Low battery" "Get yo changer asap"
    fi
}

path_pid="/tmp/polybar-battery.pid"

case "$1" in
    --update)
        pid=$(cat $path_pid)

        if [ "$pid" != "" ]; then
            kill -10 "$pid"
        fi
        ;;
    *)
        echo $$ > $path_pid

        trap exit INT
        trap "echo" USR1

        while true; do
            battery_print
            sleep 30 &
            wait
        done
        ;;
esac
