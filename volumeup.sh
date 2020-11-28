#!/bin/sh
amixer --quiet sset Master 5%+ && [ $(amixer sget Master | awk -F"[][]" '/Left:/ { print $2 }' | sed 's/.$//') -eq 100 ] && notify-send "100" -t 1000
#gdbus call --session --dest org.freedesktop.Notifications \
#  --object-path /org/freedesktop/Notifications \
#  --method org.freedesktop.Notifications.Notify \
#    'gnome-settings-daemon' \
#    0 \
 #   'notification-audio-volume-medium' \
  #  ' ' \
  #  '' \
  #  [] \
  #  "{'x-canonical-private-synchronous': <'volume'>, 'value': <124>}" \
   # 1

#notify-send -c notification-audio-volume-medium -h int:value:56 volume-up

#gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.Notify volume-up 94 audio-volume-high 64 [] {} 20000

#VOLUME=$(echo $AMIXER | grep 'Right:' | awk -F'[][]' '{ print $2 }' | tr -d "%")
