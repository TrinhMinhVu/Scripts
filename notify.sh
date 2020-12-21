#!/bin/bash
id=15
sed -i "2s/.*/id=$(gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.Notify APPLICATION $id $1 "Volume" "$2" [] {} 1000 | sed -e "s|.* \(.*\),.*|\1|")/" $HOME/Scripts/notify.sh
exit 0