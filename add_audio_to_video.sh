#!/bin/bash


ffmpeg -i file:"$2" -i file:"$1" -shortest -c:v copy -c:a aac -b:a 256k $2-audio.mp4
