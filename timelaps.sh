#!/bin/bash
dunstify -t 1000 "Timelap started" "Will be saves in Videos/timelaps/" && ffmpeg -framerate 1 -f x11grab -s 1920,1080 -i :0.0+0,0 -vf settb=\(1/30\),setpts=N/TB/30 -r 30 -vcodec libx264 -crf 0 -preset ultrafast -threads 0 /home/mx-vu/Videos/timelaps/$(date +%Y_%m_%d_%T).mkv
