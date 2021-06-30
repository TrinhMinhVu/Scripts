#!/bin/bash
ffmpeg -i file:"$1" -r 30 -filter:v "setpts=0.01667*PTS" -vcodec libx264 -an $1-better.mkv
