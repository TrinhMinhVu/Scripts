#!/bin/bash

ffmpeg -i $1 -c:v libx264rgb -crf 0 -preset veryslow output-$1-re_encode.mkv
