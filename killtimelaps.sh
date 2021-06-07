#!/bin/bash
pgrep timelaps.sh && killall --user $USER --ignore-case --signal INT ffmpeg && killall --user $USER --ignore-case --signal INT timelaps.sh && dunstify -t 3000 "Timelap stopped" "Saved in Videos/timelaps/"
