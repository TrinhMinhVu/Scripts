#!/usr/bin/env bash
query=""

if [[ -z "$1" ]]; then
  printf "Search query: ";
  query=$( echo | dmenu -p "Search YT Video")
else
	query="$1"
fi

if [[ -n "$query" ]]; then
	#if [[ -z "$(grep -w "https://www.youtu" <<< "$query")" ]]; then
query="${query// /+}"

# YT_API_KEY location from https://console.developers.google.com/apis/credentials?project=plasma-column-300712
YT_API_KEY="$( cat "${HOME}"/.local/yt_api )"
urlstring="https://www.googleapis.com/youtube/v3/search?part=snippet&q=${query}&type=video&maxResults=30&key=${YT_API_KEY}"

# select video
video="$( curl -s "${urlstring}" \
	| jq -r '.items[] | "\(.snippet.title); 📺:\(.snippet.channelTitle) 📸:\(.snippet.liveBroadcastContent) 🔎: youtu.be/\(.id.videoId)"' \
	| dmenu -l 15 -i -p 'Select Video -' \
	| awk '{print $NF " " $(NF-2)}' \
)"
	# if no video is selected quit the script, otherwise choose quality
	if [[ "$video" != " " && -n "$video" ]]; then
	quality="$(youtube-dl -F https://"${video% *}" | grep "avc1\|m4a_dash" \
		| awk '{print $4 " " $3 " code: " $1 " " $9 " " $NF}' \
		| dmenu -l 15 -i -p "Select Quality -" \
		| awk '{print $4}' )"
		# if quality is not select then just quit
		if [[ -z $quality ]]; then
			exit 0

		# if quality is 140 which means only audio then launch mpv inside a terminal
		elif [[ $quality = "140" ]]; then
			xfce4-terminal -e "mpv --script-opts=ytdl_hook-ytdl_path=youtube-dl --ytdl-format=$quality https://${video% *}"

		# if quality is either 720p30 or 360p30 or is streaming then say less
		elif [[ $quality = "22" || $quality = "18" || "${video:${#video}-4:4}" = "live" ]]; then
			mpv --script-opts=ytdl_hook-ytdl_path=youtube-dl --ytdl-format=$quality https://${video% *} &
		else # if quality is other then need to add audio cus no audio by default
			mpv --script-opts=ytdl_hook-ytdl_path=youtube-dl --ytdl-format=$quality+140 https://${video% *} &
		fi
	else
		exit 0
	fi

    #else
#	    mpv $query &
    #fi

else
	exit 0
fi
