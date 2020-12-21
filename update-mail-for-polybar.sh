#!/bin/bash
pkill -9 -f ".local/bin/mail.sh"

while true; do
sleep 900 && exec $HOME/.local/bin/mail.sh && polybar-msg hook mail 1
done