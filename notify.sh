#!/bin/bash
id=328
sed -i "2s/.*/id=$(gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.Notify APPLICATION $id $1 "Volume" "$2" [] {} 2500 | sed -e "s|.* \(.*\),.*|\1|")/" ./bruh.sh

#sed -i "2s/.*/id=$(gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.Notify APPLICATION $id audio-volume-low "Message" "Body" [] {} 2500 | sed -e "s|.* \(.*\),.*|\1|")/" ./bruh.sh