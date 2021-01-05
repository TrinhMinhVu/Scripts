#!/usr/bin/env bash
query=""

if [[ -z "$1" ]]; then
  printf "Search query: "; 
  query=$( echo | rofi -dmenu -p "Search YT Video" -theme "~/.cache/wal/colors-rofi-dark.rasi")
else
	query="$1"
fi

if [[ -n "$query" ]]; then
query="${query// /+}"

# YT_API_KEY location
YT_API_KEY="$( cat "${HOME}"/.local/api_keys/YT_API_KEY )"
urlstring="https://www.googleapis.com/youtube/v3/search?part=snippet&q=${query}&type=video&maxResults=30&key=${YT_API_KEY}"

# select video
video="$( curl -s "${urlstring}" \
	| jq -r '.items[] | "\(.snippet.title); 📺:\(.snippet.channelTitle) 📸:\(.snippet.liveBroadcastContent) 🔎: youtu.be/\(.id.videoId)"' \
	| rofi -dmenu -i -p 'Select Video -' -theme "~/.cache/wal/colors-rofi-dark.rasi" \
	| awk '{print $NF " " $(NF-2)}' \
)"
	# if no video is selected quit the script, otherwise choose quality
	if [[ "$video" != " " ]]; then
	quality="$(youtube-dl -F https://"${video% *}" | grep "avc1\|m4a_dash" \
		| awk '{print $4 " " $3 " code: " $1 " " $9 " " $NF}' \
		| rofi -dmenu -i -p 'Select Quality -' -select "(best)"  -theme "~/.cache/wal/colors-rofi-dark.rasi" \
		| awk '{print $4}' \
	)"
		# if quality is not select then just quit
		if [[ -z $quality ]]; then
			exit 0
		# if quality is either 720p30 or 360p30 or is streaming then say less
		elif [[ $quality = "22" || $quality = "18" || "${video:${#video}-4:4}" = "live" ]]; then
			mpv --ytdl-format=$quality https://${video% *} &
		else # if quality is other then need to add audio cus no audio by default
			mpv --ytdl-format=$quality+140 https://${video% *} &
		fi
	else
		exit 0
	fi

else 
	exit 0
fi
