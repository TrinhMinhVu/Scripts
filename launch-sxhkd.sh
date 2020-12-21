#!/bin/bash

# Terminate already running bar instances
killall -q sxhkd

# Wait until the processes have been shut down
while pgrep -u $UID -x sxhkd >/dev/null; do sleep 1; done

# Launch sxhkd, using default config location ~/.config/polybar/config
sxhkd &