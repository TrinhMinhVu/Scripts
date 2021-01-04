#!/usr/bin/env bash
query=""

if [[ -z "$1" ]]; then
  printf "Search query: "; 
  query=$( echo | rofi -dmenu -p "Search YT Video:" -theme "~/.cache/wal/colors-rofi-dark.rasi")
else
	query="$1"
fi

echo "$query"
if [[ -n "$query" ]]; then
query="${query// /+}"
echo "$query"

# YT_API_KEY location
YT_API_KEY="$( cat "${HOME}"/.local/api_keys/YT_API_KEY )"
urlstring="https://www.googleapis.com/youtube/v3/search?part=snippet&q=${query}&type=video&maxResults=30&key=${YT_API_KEY}"

mpv "https://$( curl -s "${urlstring}" \
	| jq -r '.items[] | "\(.snippet.title); from \(.snippet.channelTitle); Id=youtu.be/\(.id.videoId)"' \
	| rofi -dmenu -i -p 'Select Video -' -theme "~/.cache/wal/colors-rofi-dark.rasi" \
	| awk '{print $NF}' \
)" &
else 
	exit 0
fi
