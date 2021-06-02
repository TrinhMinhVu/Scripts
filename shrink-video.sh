#!/bin/bash

case "$1" in
	"-e")
		ffmpeg -i $2 -vcodec libx265 -crf 28 $2-re-encode.mp4
		echo -e "Finish re-encoding\n$(du -h $2)\nto\n$(du -h $2-re-encode.mp4)"
		;;
	"-r")
		ffmpeg -i $2 -vf "scale=iw/3:ih/3" $2-re-size-3-1.mp4
		echo -e "Finish re-sizing, from 3 to 1\n$(du -h $2)\nto\n$(du -h $2-re-size.mp4)"
		;;
	*)
		ffmpeg -i $1 -vcodec libx265 -crf 28 -vf "scale=iw/3:ih/3" $1-re-size-re-encode.mp4
		echo -e "Finish re-encoding and re-sizing, from 3 to 1\n$(du -h $1)\nto\n$(du -h $2-re-size-re-encode.mp4)"
		;;
esac



