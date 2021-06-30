#!/bin/bash
ffmpeg -f pulse -i default -video_size 1920x1080 -framerate 60 -f x11grab -i :0.0 -c:v libx264rgb -crf 0 -preset ultrafast /home/mx-vu/Videos/records/ffmpeg/$(date +%Y_%m_%d_%T).mkv
