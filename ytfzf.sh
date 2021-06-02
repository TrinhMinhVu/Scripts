#!/bin/sh

######################################
#> https://github.com/pystardust/ytfzf
######################################

YTFZF_VERSION="1.1.5"

############################
#         Defaults         #
############################


#>reading the config file
config_dir=${YTFZF_CONFIG_DIR-$HOME/.config/ytfzf}
config_file=${YTFZF_CONFIG_FILE-$config_dir/conf.sh}
tmp_video_data_file="/tmp/ytfzf-subdata"
#source config file if exists
[ -e "$config_file" ] && . "$config_file"

#for each environment variable, check if it's set in environment,
    #if set in environment, use that value
    #otherwise use the variable set in config, if that's not set, use the default value

#enable/disable history
[ -z "$YTFZF_HIST" ] && YTFZF_HIST=${enable_hist-1}
#enable/disable looping
[ -z "$YTFZF_LOOP" ] && YTFZF_LOOP=${enable_loop-0}
#enable/disable outputting current track to $current_file
[ -z "$YTFZF_CUR" ] && YTFZF_CUR=${enable_cur-1}
#enable/disable notification
[ -z "$YTFZF_NOTI" ] && YTFZF_NOTI=${enable_noti-0}
#the cache directory
[ -z "$YTFZF_CACHE" ] && YTFZF_CACHE=${cache_dir-$HOME/.cache/ytfzf}
#video type preference (mp4/1080p, mp4/720p, etc..)
[ -z  "$YTFZF_PREF" ] && YTFZF_PREF=${video_pref-}
#the menu to use instead of fzf when -D is specified
[ -z "$YTFZF_EXTMENU" ] && YTFZF_EXTMENU=${external_menu-dmenu -i -l 30 -p Search:}
#number of columns (characters on a line) the external menu can have
#necessary for formatting text for external menus
[ -z "$YTFZF_EXTMENU_LEN" ] && YTFZF_EXTMENU_LEN=${external_menu_len-220}

## player settings (players need to support streaming with youtube-dl)
#player to use for watching the video
[ -z "$YTFZF_PLAYER" ] && YTFZF_PLAYER=${video_player-mpv}
#if YTFZF_PREF is specified, use this player instead
[ -z "$YTFZF_PLAYER_FORMAT" ] && YTFZF_PLAYER_FORMAT=${video_player_format-mpv --ytdl-format=}
#player to use for audio only
[ -z "$YTFZF_AUDIO_PLAYER" ] && YTFZF_AUDIO_PLAYER=${audio_player-mpv --no-video}
#Storing the argument and location for auto-generated subtitles
[ -z "$YTFZF_SUBT_NAME" ] && YTFZF_SUBT_NAME=""
#Stores the language for the auto generated subtitles
[ -z "$YTFZF_SELECTED_SUB" ] &&  YTFZF_SELECTED_SUB=""


#> Clearing/Enabling fzf_defaults
#enable/disable the use of FZF_DEFAULT_OPTS
[ -z "$YTFZF_ENABLE_FZF_DEFAULT_OPTS" ] && YTFZF_ENABLE_FZF_DEFAULT_OPTS=${enable_fzf_default_opts-0}
#clear FZF_DEFAULT_OPTS
[ "$YTFZF_ENABLE_FZF_DEFAULT_OPTS" -eq 0 ] && FZF_DEFAULT_OPTS=""

#> files and directories
history_file=${history_file-$YTFZF_CACHE/ytfzf_hst}
current_file=${current_file-$YTFZF_CACHE/ytfzf_cur}
thumb_dir=${thumb_dir-$YTFZF_CACHE/thumb}
#> Stores urls of the video page of channels
subscriptions_file=${subscriptions_file-$config_dir/subscriptions}

#> stores the pid of running ytfzf sessions
pid_file="$YTFZF_CACHE/.pid"
#> make folders that don't exist
[ -d "$YTFZF_CACHE" ] || mkdir -p "$YTFZF_CACHE"
[ -d "$thumb_dir" ] || mkdir -p "$thumb_dir"

#> config settings
search_prompt=${search_prompt-Search Youtube: }
#used when getting the html from YouTube
useragent=${useragent-'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.152 Safari/537.36'}

#Opt variables (can also be set in config)
#use $YTFZF_EXT_MENU (same as -D)
is_ext_menu=${is_ext_menu-0}
#show thumbnails (same as -t)
show_thumbnails=${show_thumbnails-0}
# 0: better thumbnails (slower), 1: low res thumbnails (faster)
thumbnail_quality=${thumbnail_quality-1}
#auto select the first video (same as -a)
auto_select=${auto_select-0}
#select all results (same as -A)
select_all=${select_all-0}
#randomly select a video (same as -r)
random_select=${random_select-0}
#only show the selected link (same as -L)
show_link_only=${show_link_only-0}
#show different video formats (same as -f)
show_format=${show_format-0}
#number of links to select with -a or -r (same as -n)
link_count=${link_count-1}
#number of videos to show in the subscription menu
sub_link_count=${sub_link_count-10}
#after video ends, make another search (same as -s)
search_again=${search_again-0}
#whether or not to show -----------channel------------ when looking at subscriptions
fancy_subscriptions_menu=${fancy_subscriptions_menu-1}
#sort subscriptions subsections based on time instead of channel
sort_videos_data=${sort_videos_data-0}
#filter id used when searching
sp=${sp-}
#is used to know whether or not scraping the search page is necessary
scrape=${scrape-yt_search}
#auto generated caption by YouTube with enabled with --subt
auto_caption=${auto_caption-0}
#only play/download the audio if set to 1
is_audio_only=${is_audio_only-0}
#flag for downloading
is_download=0
#the tab for trending, empty is the default page
trending_tab="${trending_tab-}"
# misc
tab_space=$(printf '\t')

#ueberzug related variables
#the side where thumbnails are shown
#needs to be exported because ueberzug spawns subprocesses
[ -z "$PREVIEW_SIDE" ] && export PREVIEW_SIDE=${preview_side-left}

#variable used for when this process spawns subprocesses and there needs to be a unique value (ueberzug)
#this could be any unique value, $$ is used because it is the most easily accessible unique value
if [ -z "$PROC_ID" ]; then
	export PROC_ID=$$
	printf "$$\n" >> "$pid_file"
fi

#dependency check
dep_ck () {
	for Dep; do
		if ! command -v "$Dep" 1>/dev/null; then
			printf "%s not found. Please install it.\n" "$Dep"
			exit 2
		fi
	done
	unset Dep
}
dep_ck "jq" "youtube-dl" "curl"

#only check for mpv if $YTFZF_PLAYER is set to it
#don't check $YTFZF_PLAYER as it could be multiple commands
[ "$YTFZF_PLAYER" = "mpv" ] && dep_ck "mpv"

############################
#       Help Texts         #
############################

basic_helpinfo () {
	while IFS= read -r Line; do
		printf "%s\n" "$Line";
	done <<EOF
Usage: ytfzf [OPTIONS...] <search-query>;
  OPTIONS:
     -h, --help                             Show this help text;
     -v, --version                          -v for ytfzf's version;
                                            --version for ytfzf + dependency's versions
     -t, --show-thumbnails                  Show thumbnails (requires ueberzug)
     -N, --notification                     Send notification when playing video
                                            Doesn't work with -H -D
     --thumbnail-quality=<0,1>              0: low quality (faster), 1: default
     -D, --ext-menu                         Use external menu (default dmenu) instead of fzf
     -H, --choose-from-history              Choose from history
     -x, --clear-history                    Delete history
     -m, --audio-only     <search-query>    Audio only (for music)
     -d, --download       <search-query>    Download to current directory
     -f                   <search-query>    Show available formats before proceeding
     -a, --auto-select    <search-query>    Auto play the first result, no selector
     -r  --random-select  <search-query>    Auto play a random result, no selector
     -A, --select-all     <search-query>    Selects all results
     -n, --link-count=    <link-count>      To specify number of videos to select with -a, -r
     -l, --loop           <search-query>    Loop: prompt selector again after video ends
     -s, --search-again   <search-query>    After the video ends make another search
     -L, --link-only      <search-query>    Prints the selected URL only, helpful for scripting
     -T, --trending=      <gaming/music/movies>      The trending tab, using --trending= you can choose a specific tab
     --preview-side=      <left/right/top/bottom>    The side of the screen to show thumbnails
     --subt                                 Select auto-generated subtitles
     --sort                                 Sorts videos by latest upload date

  Use - instead of <search-query> for stdin

  Option usage:
     ytfzf -fDH                             to show history using external
                                            menu and show formats
     ytfzf -fD --choose-from-history        same as above

EOF
}

all_help_info () {
	basic_helpinfo
	while IFS= read -r Line; do
		printf "%s\n" "$Line";
	done <<EOF
  Subscriptions: to add a channel to subscptions, copy the channel's video page url
                 and add it to ~/.config/ytfzf/subscriptions. Each url must be on a new line
     -S,  --subs                          Get the latest 10 videos from subscriptions
     --subs=<number>                      Get the latest <number> of videos from subscriptions
     --fancy-subs=                        whether or not to show ------channel------ in subscriptions (must be 1 or 0)
     --add-subs				  generate a subscriptions file with subscriptions.json that you can get from google
                                          visit https://github.com/FreeTubeApp/FreeTube/wiki/Importing-Your-YouTube-Subscriptions for more info
  Filters: different ways to filter videos in search
     --upload-time=     <time-range>      Time range can be one of,
                                          last-hour, today, this-week, this-month, this-year
                                          Filters can go directly: --today
     --upload-sort=     <sort-filter>     The filter to sort the videos can be one of
                                          upload-date, view-count, rating
                                          Filters can go directly: --upload-date
     --filter-id=       <filter>          The id of the filter to use for video results
         A filter id can be found by going to Youtube searching, filtering how you want
         Then taking the value of the &sp= part of the url
         Filters may not work especially when the filter sorts for non-videos
         In addition this overrides any filter provided through options
         Example: ytfzf --filter-id=EgJAAQ minecraft
         This will filter by livestream

  Update:
     --update                             clones the latest stable commit and installs it
                                          on Arch ytfzf is available in the AUR
     --update-unstable                    gets the latest commit and installs it (--update is safer)


  Defaults can be modified through ENV variables or the config file
  the default config file can be found at https://github.com/pystardust/ytfzf/blob/master/docs/conf.sh

  Environment Variables:
     YTFZF_HIST=1                                       0 : off history
     YTFZF_NOTI=1                                       0 : turn off notification
     YTFZF_CACHE=~/.cache/ytfzf;
     YTFZF_CONFIG_DIR='~/.config/ytfzf'                 The directory to store config files
     YTFZF_CONFIG_FILE='\$YTFZF_CONFIG_DIR/conf.sh'     The configuration file
     YTFZF_LOOP=0                                       1 : loop the selection prompt
     YTFZF_PREF=''                                      22: 720p,  18: 360p (yt-dl formats)
     YTFZF_CUR=1                                        For status bar modules
     YTFZF_ENABLE_FZF_DEFAULT_OPTS=0                    1 : fzf will use FZF_DEFAULT_OPTS
     YTFZF_SELECTED_SUB=en                              Set default auto caption language (eg. English)
     YTFZF_EXTMENU=' dmenu -i -l 30'
  To use rofi: YTFZF_EXTMENU=' rofi -dmenu -fuzzy -width 1500'

EOF
}

usageinfo () {
    printf "Usage: %bytfzf %b<search query>%b\n" "\033[1;32m" "\033[1;33m" "\033[0m";
    printf "     'ytfzf -h' for more information\n";
}

print_error () {
    printf "$*"
    printf "Check for new versions and report at: https://github.com/pystardust/ytfzf\n"
}


############################
#        Formatting        #
############################
#> Colors  (printf)
c_red="\033[1;31m"
c_green="\033[1;32m"
c_yellow="\033[1;33m"
c_blue="\033[1;34m"
c_magenta="\033[1;35m"
c_cyan="\033[1;36m"
c_reset="\033[0m"


#> To determine the length of each field (title, channel ... etc)
format_ext_menu () {
	#base how much space everything takes up depending on the width of YTFZF_EXT_MENU
	frac=$(((YTFZF_EXTMENU_LEN - 5 - 12)/11))
	#title space
	title_len=$((frac * 6 - 1))
	#channel space
	channel_len=$((frac * 3/2))
	#video duration space
	dur_len=$((frac * 1))
	#video view space
	view_len=$((frac * 1))
	#video upload date space
	date_len=$((frac * 3/2 + 100 ))
	#url space
	url_len=12
}
format_fzf () {
	dur_len=7
	view_len=10
	date_len=14
	url_len=12

	#*_len works the same as it does in format_ext_menu
	#show title, channel
	if [ "$TTY_COLS" -lt 75 ]; then
		frac=$(((TTY_COLS - 1)/4))
		title_len=$((frac * 3))
		channel_len=$((frac * 1 + 7))
	#show title, channel, time
	elif [ "$TTY_COLS" -lt 95 ]; then
		frac=$(((TTY_COLS - 4)/8))
		title_len=$((frac * 5 - 1))
		channel_len=$((frac * 2 - 1))
		dur_len=$((frac * 1 + 10))
	#show title, channel, time, views
	elif [ "$TTY_COLS" -lt 110 ]; then
		frac=$(((TTY_COLS - 1)/9))
		title_len=$((frac * 5 ))
		channel_len=$((frac * 2 ))
		dur_len=$((frac * 1))
		view_len=$((frac * 1 + 7))
	#show title, channel, time, views, date
	else
		frac=$((TTY_COLS/10 ))
		title_len=$((frac * 5 - 1))
		channel_len=$((frac * 2))
		dur_len=$((frac * 1 - 5 ))
		view_len=$((frac * 1))
		date_len=$((frac * 2 + 20))
	fi
}
#> Formats the fields depending on which menu is needed. And assigns the menu command.
format_menu () {
	if [ "$is_ext_menu" -eq 0 ]; then
		#dep_ck fzf here because it is only necessary to use here
		dep_ck "fzf"
		menu_command='column -t -s "$tab_space" | fzf -m --bind change:top --tabstop=1 --layout=reverse --delimiter="$tab_space" --nth=1,2 $FZF_DEFAULT_OPTS'
		format_fzf
	else
		# Dmenu doesn't render tabs so removing it
		menu_command='tr -d "$tab_space" | '"$YTFZF_EXTMENU"
		format_ext_menu
	fi
}

function_exists () {
	if type "$1" > /dev/null 2>&1; then
	    return 0
	else
	    return 1
	fi
}

# video_info_text can be set in the conf.sh, if set it will be preferred over the default given below
if ! function_exists 'video_info_text'; then
	video_info_text () {
		printf "%-${title_len}.${title_len}s\t" "$title"
		printf "%-${channel_len}.${channel_len}s\t" "$channel"
		printf "%-${dur_len}.${dur_len}s\t" "$duration"
		printf "%-${view_len}.${view_len}s\t" "$views"
		printf "%-${date_len}.${date_len}s\t" "$date"
		printf "%-${url_len}.${url_len}s\t" "$shorturl"
		printf "\n"
	}
fi

format_video_data () {
	while IFS=$tab_space read -r title channel views duration date shorturl; do
	    video_info_text
	done << EOF
$*
EOF
	unset title channel duration views date shorturl
}

############################
#       Image previews     #
############################

if ! function_exists 'thumbnail_video_info_text' ; then
    thumbnail_video_info_text () {
	printf "\n ${c_cyan}%s" "$title"
	printf "\n ${c_blue}Channel	${c_green}%s" "$channel"
	printf "\n ${c_blue}Duration	${c_yellow}%s" "$duration"
	printf "\n ${c_blue}Views	${c_magenta}%s" "$views"
	printf "\n ${c_blue}Date	${c_cyan}%s" "$date"
    }
fi

## The following snippet of code has been copied and modified from
# https://github.com/OliverLew/fontpreview-ueberzug      MIT License
# Ueberzug related variables

#the is doesn't have to be the $$ it just has to be unique for each instance of the script
#$$ is the easiest unique value to access that I could think of

FIFO="/tmp/ytfzf-ueberzug-fifo-$PROC_ID"
ID="ytfzf-ueberzug"
WIDTH=$FZF_PREVIEW_COLUMNS
HEIGHT=$FZF_PREVIEW_LINES
start_ueberzug () {
    [ -e $FIFO ] || { mkfifo "$FIFO" || exit 1 ; }
    ueberzug layer --parser json --silent < "$FIFO" &
    exec 3>"$FIFO"
}
stop_ueberzug () {
    exec 3>&-
    rm "$FIFO" > /dev/null 2>&1
}

preview_img () {

	# remove trailing spaces from each field and separate them with just a tab
	preview_data=$( printf '%s' "$*" | sed "s/ *$tab_space|/$tab_space/g" )

	IFS=$tab_space read -r title channel duration views date shorturl << EOF
$preview_data
EOF

	if [ -z "${shorturl%% *}" ] ; then
		printf "\n${c_cyan}%s${c_reset}\n" "$title"
		printf '{ "action": "remove", "identifier": "%s" }\n' "$ID" > "$FIFO"
		return
	fi

	# Out put the formatted text on the (left)panel
	thumbnail_video_info_text

	thumb_width=$((WIDTH - 2 ))
	thumb_height=$((HEIGHT - 2))
	#most common x, y positions

	thumb_x=$((TTY_COLS / 2 + 3))
	thumb_y=10

	case $PREVIEW_SIDE in
	    left)
		thumb_x=1
		;;
	    top)
		thumb_height=$((HEIGHT - 5))
		thumb_y=2
		;;
	    bottom)
		thumb_height=$((HEIGHT - 5))
		thumb_y=$((TTY_LINES / 2 + 3))
		;;
	esac

	# In fzf the cols and lines are those of the preview pane
	IMAGE="$thumb_dir/${shorturl%% *}.png"
	{   printf '{ "action": "add", "identifier": "%s", "path": "%s",' "$ID" "$IMAGE"
	    printf '"x": %d, "y": %d, "scaler": "fit_contain",' $thumb_x $thumb_y
	    printf '"width": %d, "height": %d }\n' "$thumb_width" "$thumb_height"
	} > "$FIFO"
	unset title channel duration views date shorturl
	unset thumb_width thumb_height thumb_x thumb_y IMAGE
}

############################
#   Video selection Menu   #
############################
video_menu () {
	#take input format it to the appropriate format, then pipe it into the menu
	format_video_data "$*" | eval "$menu_command"
}


############################
#         Scraping         #
############################

download_thumbnails () {
       #scrapes the urls of the thumbnails of the videos from the adjusted json
	if [ "$thumbnail_quality" -eq 1 ]; then
		image_download () {
			# higher quality images
			curl -s "$Url" -G --data-urlencode "sqp=" > "$thumb_dir/$Name.png"
		}
	else
		image_download () {
 			curl -s "$Url"  > "$thumb_dir/$Name.png"
		}
	fi

	[ "$show_link_only" -eq 0 ] && printf "Downloading Thumbnails...\n"
	thumb_urls=$(printf "%s" "$*" |\
		jq  -r '.[]|[.thumbs,.videoID]|@tsv' )

	while IFS=$tab_space read -r Url Name; do
		sleep 0.001
		{
			image_download
		} &
	done <<-EOF
	$thumb_urls
	EOF
	unset Name Url thumb_urls
	unset -f image_download
}

get_sp_filter () {

	#filter_id is a variable that keeps changing throught this function
	filter_id=

	#sp is the final filter id that is used in the search query
	sp=

	#the way youtube uses these has a pattern, for example
	    #in the sort_by_filter the only difference is the 3rd character, I just don't know how to use this information efficiently
	case $sort_by_filter in
		upload-date) filter_id="CAISBAgAEAE" ;;
		view-count) filter_id="CAMSBAgAEAE" ;;
		rating) filter_id="CAESBAgAEAE" ;;
	esac

	#another example is sort by filter + upload date filter only changes one character as well
	if [ -n "$filter_id" ]; then
		#gets the character in the filter_id that needs to be replaced if upload_date_filter is also given
		upload_date_character=$(printf "%s" "$filter_id" | awk '{print substr($1, 8, 1)}')
	fi

	#For each of these, if upload_date_character is unset, the filter_id should be the normal filter
	#Otherwise set the upload_date_character to the right upload_date_character
	case $upload_date_filter in
		last-hour)
			[ -z "$upload_date_character" ] && filter_id="EgQIARAB" || upload_date_character="B" ;;
		today)
			[ -z "$upload_date_character" ] && filter_id="EgQIAhAB" || upload_date_character="C" ;;
		this-week)
			[ -z "$upload_date_character" ] && filter_id="EgQIAxAB" || upload_date_character="D" ;;
		this-month)
			[ -z "$upload_date_character" ] && filter_id="EgQIBBAB" || upload_date_character="E" ;;
		this-year)
			[ -z "$upload_date_character" ] && filter_id="EgQIBRAB" || upload_date_character="F" ;;
	esac

	#if upload_date_character isn't empty, set sp to upload_date filter + sort_by filter
	if [ -n "$upload_date_character" ]; then
		#replaces the 8th character in the filter_id with the appropriate character
		#the 8th character specifies the upload_date_filter
		sp=$(printf "%s" "$filter_id" | sed "s/\\(.\\{7\\}\\)./\\1$upload_date_character/")
	#otherwise set it to the filter_id
	else
		sp=$filter_id
	fi
	unset upload_date_character filter_id
}

get_yt_json () {
	# scrapes the json embedded in the youtube html page
	printf "%s" "$*" | sed -n '/var *ytInitialData/,$p' | tr -d '\n' |\
        sed -E ' s_^.*var ytInitialData ?=__ ; s_;</script>.*__ ;'
}

get_yt_html () {
    link=$1
    query=$2
    printf "%s" "$(
	curl "$link" -s \
	  -G --data-urlencode "search_query=$query" \
	  -G --data-urlencode "sp=$sp" \
	  -H 'authority: www.youtube.com' \
	  -H "user-agent: $useragent" \
	  -H 'accept-language: en-US,en;q=0.9' \
	  -L \
	  --compressed
    )"
    unset link query
}

get_video_data () {
	# outputs tab and pipe separated fields: title, channel, view count, video length, video upload date, and the video id/url
	# from the videos_json
	printf "%s" "$*" |\
		jq -r '.[]| "\(.title)'"$tab_space"'|\(.channel)'"$tab_space"'|\(.views)'"$tab_space"'|\(.duration)'"$tab_space"'|\(.date)'"$tab_space"'|\(.videoID)"'
}

scrape_channel () {
	# needs channel url as $*
	## Scrape data and store video information in videos_data ( and thumbnails )

	channel_url=$*

	# Converting channel title page url to channel video url
	if ! printf "%s" "$channel_url" | grep -q '/videos *$'; then
		channel_url=${channel_url%/featured}/videos
	fi

	yt_html=$(get_yt_html "$channel_url")

	if [ -z "$yt_html" ]; then
	        print_error "\033[31mERROR[#01]: Couldn't curl website. Please check your network and try again.\033[0m\n"
	        exit 1
	fi

	#gets the channel name from title of page
	channel_name=$(printf "%s" "$yt_html" | grep -o '<title>.*</title>' |
		sed \
		-e 's/ - YouTube//' \
		-e 's/<\/\?title>//g' \
		-e "s/&apos;/'/g" \
		-e "s/&#39;/'/g" \
		-e "s/&quot;/\"/g" \
		-e "s/&#34;/\"/g" \
		-e "s/&amp;/\&/g" \
		-e "s/&#38;/\&/g"
		)

	#gets json of videos
	yt_json=$(get_yt_json "$yt_html")

	#gets a list of videos
	videos_json=$(printf "%s" "$yt_json" |\
	jq '[ .contents | ..|.gridVideoRenderer? |
	select(. !=null) |
	    {
	    	title: .title.runs[0].text,
	    	channel:"'"$channel_name"'",
	    	duration:.thumbnailOverlays[0].thumbnailOverlayTimeStatusRenderer.text.simpleText,
	    	views: .shortViewCountText.simpleText,
	    	date: .publishedTimeText.simpleText,
	    	videoID: .videoId,
	    	thumbs: .thumbnail.thumbnails[0].url,
	    }
	]')

	videos_json=$(printf "%s" "$videos_json" | jq '.[0:'$sub_link_count']')
	videos_data=$(get_video_data "$videos_json")

	#if there aren't videos
	[ -z "$videos_data" ] &&  { printf "${c_yellow}No results found. Make sure the link ($channel_url) is correct.${c_reset}\n(if this chnanel has not uploaded videos this warning may appear)\n"; exit 1;}
	if [ $fancy_subscriptions_menu -eq 1 ]; then
		printf "             -------%s-------\t\n%s\n" "$channel_name" "$videos_data" >> "$tmp_video_data_file"
	else
		printf "%s\n" "$videos_data" >> "$tmp_video_data_file"
	fi

	[ $show_thumbnails -eq 1 ] && download_thumbnails "$videos_json"
	unset channel_url channel_name yt_html yt_json  videos_json
}

get_trending_url_data () {
    case "$trending_tab" in
	music) printf "%s" "4gINGgt5dG1hX2NoYXJ0cw%3D%3D" ;;
	gaming) printf "%s" "4gIcGhpnYW1pbmdfY29ycHVzX21vc3RfcG9wdWxhcg%3D%3D" ;;
	movies) printf "%s" "4gIKGgh0cmFpbGVycw%3D%3D" ;;
    esac
}

scrape_yt () {
	# needs search_query as $*
	## Scrape data and store video information in videos_data ( and thumbnails )

	#sp is the urlquery youtube uses for sorting videos
	#only runs if --filter-id or --sp was unspecified
	if [ -z "$sp" ]; then
		get_sp_filter
	else
		#youtube puts in %253d one ore more times in the filter id, it doesn't seem useful, so we are removing it if it's in the filter
		sp=${sp%%%*}
	fi

	[ $show_link_only -eq 0 ] && printf "Scraping Youtube...\n"

	if [ "$scrape" = "trending" ]; then
	    tab_data="$(get_trending_url_data)"
	    [ -z "$tab_data" ] && [ -n "$trending_tab" ] && printf "\033[31mERROR[#05]: \033[1m\$trending_tab\033[0m\033[31m must be one of:\n\033[2;39mmusic, gaming, movies\033[0m\n\033[31myou put: \033[1m\"$trending_tab\"\033[0m\n" && exit 2
	    yt_html=$(get_yt_html "https://www.youtube.com/feed/trending?bp=$tab_data")
	else
	    yt_html=$(get_yt_html "https://www.youtube.com/results" "$*")
	fi

	if [ -z "$yt_html" ]; then
		print_error "\033[31mERROR[#01]: Couldn't curl website. Please check your network and try again.\033[0m\n"
		exit 1
	fi

	yt_json=$(get_yt_json "$yt_html")

	#if the data couldn't be found
	if [ -z "$yt_json" ]; then
		print_error "\033[31mERROR[#02]: Couldn't find data on site.\033[0m\n"
		exit 1
	fi

	#gets a list of videos
	videos_json=$(printf "%s" "$yt_json" | jq '[ .contents|
	..|.videoRenderer? |
	select(. !=null) |
		{
			title: .title.runs[0].text,
			channel: .longBylineText.runs[0].text,
			duration:.lengthText.simpleText,
			views: .shortViewCountText.simpleText,
			date: .publishedTimeText.simpleText,
			videoID: .videoId,
			thumbs: .thumbnail.thumbnails[0].url
		}
	]')

	videos_data=$(get_video_data "$videos_json")
	#if there aren't videos
	[ -z "$videos_data" ] &&  { printf "No results found. Try different keywords.\n"; exit 1;}

	[ "$sort_videos_data" -eq 1 ] && videos_data=$(printf "%s" "$videos_data" | sort_video_data_date)

	[ $show_thumbnails -eq 1 ] && download_thumbnails "$videos_json"
	# wait for thumbnails to download
	wait
	unset videos_json yt_json yt_html
}


############################
#      User selection      #
############################
#> To get search query
get_search_query () {
	#in case no query was provided
	if [ -z "$search_query" ]; then
		if [ "$is_ext_menu" -eq 1 ]; then
			#when using an external menu, the query will be done there
			search_query=$(printf "" | eval "$YTFZF_EXTMENU" )
		else
			#otherwise use the search prompt
			printf "$search_prompt"
			read -r search_query
		fi
		[ -z "$search_query" ] && exit 0
	fi
}
#> To select videos from videos_data
user_selection () {
	#remove subscription separators
	videos_data_clean=$(printf "%s" "$videos_data" | sed "/.*$tab_space$/d")

	#$selected_data is the video the user picked
	#picks the first n videos
	if [ "$select_all" -eq 1 ] ; then
		selected_data=$videos_data_clean
	elif [ "$auto_select" -eq 1 ] ; then
		selected_data=$(printf "%s\n" "$videos_data_clean" | sed "${link_count}"q )
	#picks n random videos
	elif [ "$random_select" -eq 1 ] ; then
		selected_data=$(printf "%s\n" "$videos_data_clean" | shuf -n "$link_count" )
	#show thumbnail menu
	elif [ "$show_thumbnails" -eq 1 ] ; then
		dep_ck "ueberzug" "fzf"
		start_ueberzug
		#thumbnails only work in fzf, use fzf
		menu_command="fzf -m --tabstop=1 --bind change:top --delimiter=\"$tab_space\" \
		--nth=1,2 $FZF_DEFAULT_OPTS \
		--layout=reverse --preview \"sh $0 -U {}\" \
        	--preview-window \"$PREVIEW_SIDE:50%:noborder:wrap\""
		selected_data=$( title_len=200 video_menu "$videos_data" )
		stop_ueberzug
		# Deletes thumbnails if no video is selected
		[ -z "$selected_data" ] && delete_thumbnails
	#show regular menu
	else
		selected_data=$( video_menu "$videos_data" )
	fi
	unset videos_data_clean
}

format_user_selection () {
	#gets a list of video ids/urls from the selected data
	shorturls=$(printf "%s" "$selected_data" | sed -E -n -e "s_.*\|([^|]+) *\$_\1_p")
	[ -z "$shorturls" ] && exit

	#for each url append the full url to the $urls string
	#through this loop, the selected data which was truncated by formatting is retrived.
	selected_urls=
	selected_data=
	for surl in $shorturls; do
		[ -z "$surl" ] && continue
		selected_urls=$(printf '%s\n%s' "$selected_urls" "https://www.youtube.com/watch?v=$surl")
		selected_data=$(printf '%s\n%s' "$selected_data" "$(printf "%s" "$videos_data" | grep -m1 -e "$surl" )")
	done
	selected_urls=$( printf "%s" "$selected_urls" | sed 1d )
	#sometimes % shows up in selected data, could throw an error if it's an invalid directive
	selected_data=$( printf "%s" "$selected_data" | sed 1d )
	unset shorturls
}

print_data () {
	if [ $show_link_only -eq 1 ] ; then
		printf "%s\n" "$selected_urls"
		exit
	fi
}

get_video_format () {
	# select format if flag given
	if [ $show_format -eq 1 ]; then
        max_quality=$(youtube-dl -F "$(printf "$selected_urls")" | awk '{print $4}' | sort -n | tail -n1 | awk -F"p" '{print $1 FS}')
        quality=$(printf "Audio 144p 240p 360p 480p 720p 1080p 1440p 2160p 4320p" | awk -F"$max_quality" '{print $1 FS}' | sed "s/ /\n/g" | eval "$menu_command" | sed "s/p//g")
		[ -z "$quality"  ] && exit;
		[ $quality = "Audio"  ] && YTFZF_PREF= && YTFZF_PLAYER="$YTFZF_AUDIO_PLAYER" || YTFZF_PREF="bestvideo[height=?$quality][vcodec!=?vp9]+bestaudio/best"

	fi
	unset max_quality quality
}

get_sub_lang () {
    if [ $auto_caption -eq 1 ]; then
        #Gets the auto generated subs and stores them in a file
        sub_list=$(youtube-dl --list-subs  --write-auto-sub "$selected_urls" | sed '/Available subtitles/,$d' | awk '{print $1}' | sed '1d;2d;3d')
        if [ -n "$sub_list" ]; then
            [ -n "$YTFZF_SELECTED_SUB" ] ||  YTFZF_SELECTED_SUB=$(printf "$sub_list" | eval "$menu_command") &&  youtube-dl  --sub-lang $YTFZF_SELECTED_SUB  --write-auto-sub --skip-download "$selected_urls" -o /tmp/ytfzf && YTFZF_SUBT_NAME="--sub-file=/tmp/ytfzf.$YTFZF_SELECTED_SUB.vtt" || printf "Auto generated subs not available."
        fi
	unset sub_list
    fi

}


open_player () {

	eval set -- "$*"

	if [ $is_audio_only -eq 1 ]; then
		YTFZF_PLAYER=$YTFZF_AUDIO_PLAYER
		YTFZF_PREF="bestaudio"
	fi

	if [ $is_download -eq 0 ]; then
		if [ -z "$YTFZF_PREF" ] || [ $is_audio_only -eq 1 ]; then
			printf "Opening Player: %s\n" "$YTFZF_PLAYER $*"
			eval "$YTFZF_PLAYER" "$@"  "$YTFZF_SUBT_NAME"
		else
			printf "Opening Player: %s\n" "$YTFZF_PLAYER_FORMAT'$YTFZF_PREF' $*"
			eval "$YTFZF_PLAYER_FORMAT'$YTFZF_PREF'"  "$@"  "$YTFZF_SUBT_NAME" || [ $? -eq 4 ] || YTFZF_PREF= open_player "$*"
		fi
	elif [ $is_download -eq 1 ]; then
		if [ -z "$YTFZF_PREF" ]; then
			eval youtube-dl "$@"  "$YTFZF_SUBT_NAME"
		else
			eval youtube-dl -f "'$YTFZF_PREF'"  "$@"  "$YTFZF_SUBT_NAME" || YTFZF_PREF= open_player "$*"
		fi
	fi
}

play_url () {
	#> output the current track to current file before playing

	[ "$YTFZF_CUR" -eq 1 ] && printf "%s" "$selected_data" > "$current_file" ;

	[ "$YTFZF_NOTI" -eq 1 ] && send_notify "$selected_data" ;

	#> The urls are quoted and placed one after the other for mpv to read
	player_urls="\"$(printf "%s" "$selected_urls" | awk  'ORS="\" \"" { print }' | sed 's/"$//' | sed 's/ "" / /')"

	open_player "$player_urls"

	#Delete the temp auto-gen subtitle file
	[ $auto_caption -eq 1 ] && rm -f "${YTFZF_SUBT_NAME#*=}"

	unset player_urls
}
#> Checks if other sessions are running, if not then deletes thumbnails
delete_thumbnails () {
	session_count=0
	while read -r pid; do
		[ -d /proc/"$pid" ] && session_count=$(( session_count + 1 ))
	done < "$pid_file"
	if [ $session_count -eq 1 ] ; then
		[ -d "$thumb_dir" ] && rm -r "$thumb_dir"
		printf "" > "$pid_file"
	fi
	unset session_count
}
#> Save and clean up before script exits
save_before_exit () {
	[ $is_url -eq 1 ] && exit
	[ $YTFZF_HIST -eq 1 ] && printf "%s\n" "$selected_data" >> "$history_file" ;
	[ $YTFZF_CUR -eq 1 ] && printf "" > "$current_file" ;
}


############################
#         Misc             #
############################
#> if the input is a url then skip video selection and play the url
check_if_url () {
	# to check if given input is a url
	url_regex='^https\?://.*'

	if { printf "%s" "$1" | grep -q "$url_regex"; } ; then
		is_url=1
		selected_urls=$(printf "%s" "$1" | tr ' ' '\n')
		scrape="url"
	else
		is_url=0
	fi
	unset url_regex
}
#> Loads history in videos_data
get_history () {
	if [ "$YTFZF_HIST" -eq 1 ]; then
		[ -e "$history_file" ] || touch "$history_file"
		#gets history data in reverse order (makes it most recent to least recent)
		hist_data=$( sed '1!G; h; $!d' "$history_file" )
		[ -z "$hist_data" ] && printf "History is empty!\n" && exit;
		#removes duplicate values from $history_data
		videos_data=$(printf "%s" "$hist_data" | uniq )
		[ "$sort_videos_data" -eq 1 ] && videos_data="$(printf "%s" "$videos_data"  | sort_video_data_date)"
	else
		printf "History is not enabled. Please enable it to use this option (-H).\n";
		exit;
	fi
	unset hist_data
}
clear_history () {
	if [ -e "$history_file" ]; then
		printf "" > "$history_file"
		printf "History has been cleared\n"
	else
		printf "\033[31mHistory file not found, history not cleared\033[0m\n"
		exit 1
	fi
}

send_notify () {
	number_video=$(printf "%s\n" "$*" | wc -l)
	video_name=$(printf "%s" "$*" | cut -d'|' -f1 )
	video_channel=$(printf "%s" "$*" | cut -d'|' -f2)
	if [ "$show_thumbnails" -eq 1 ] && [ "$number_video" -eq 1 ]; then
		video_thumb="$thumb_dir/$(printf "%s" "$selected_data" | cut -d'|' -f6).png"
		message=$(printf "$video_name\nChannel: $video_channel")
	elif [ $number_video -gt 1 ]; then
		video_thumb="$config_dir/default_thumb.png"
		message="Added $number_video video to play queue"
	else
		message=$(printf "$video_name\nChannel: $video_channel")
		video_thumb="$config_dir/default_thumb.png"
	fi
	notify-send "Current playing" "$message" -i "$video_thumb"
	unset number_video video_name video_channel message video_thumb
}

update_ytfzf () {
	branch="$1"
	updatefile="/tmp/ytfzf-update"
	curl -L "https://raw.githubusercontent.com/pystardust/ytfzf/$branch/ytfzf" -o "$updatefile"

	if sed -n '1p' < "$updatefile" | grep -q '#!/bin/sh' ; then
		chmod 755 "$updatefile"
		if [ "$(uname)" = "Darwin" ]; then
			sudo cp "$updatefile" "/usr/local/bin/ytfzf"
		else
			sudo cp "$updatefile" "/usr/bin/ytfzf"
		fi
	else
		printf "%bFailed to update ytfzf. Try again later.%b" "$c_red" "$c_reset"
	fi

	rm "$updatefile"
	exit
}

sort_video_data_date () {
	while IFS= read -r _VLine
	do
		IFS="$tab_space"
		set -- $_VLine
		_Date=${5#|}
		_Date=${_Date#Streamed}
		printf "%d\t%s\n" "$(date -d "${_Date}" '+%s')" "$_VLine"
	done | sort -nr | cut -f2-
	unset IFS _VLine _Date
}

scrape_subscriptions () {
	# clear the subfile, all subscriptions data will be dumped into this file
	: > "$tmp_video_data_file"

	[ $sort_videos_data -eq 1 ] && fancy_subscriptions_menu=0

	while IFS= read -r url; do
		scrape_channel "$url" &
	done <<-EOF
	$( sed \
	-e "s/#.*//" \
	-e "/^[[:space:]]*$/d" \
	-e "s/[[:space:]]*//g" \
	"$subscriptions_file")
	EOF
	wait
	if [ $sort_videos_data -eq 1 ]; then
		videos_data=$(sort_video_data_date < "$tmp_video_data_file")
	else
		videos_data=$(cat "$tmp_video_data_file")
	fi
}

#create subscriptions file from data downloaded from youtube
create_subs () {

    yt_sub_import_file="${config_dir}/subscriptions.json"

    # there is a decent guide on getting this data by the FreeTube devs
    if [ ! -f "$yt_sub_import_file" ]; then
        printf "\033[31mYou need to have a subscriptions.json file in the ${config_dir} directory!\033[0m\n"
        printf "For further information visit https://github.com/FreeTubeApp/FreeTube/wiki/Importing-Your-YouTube-Subscriptions !\n"
        exit
    fi

    # start fresh
    : > $config_dir/subscriptions

    # check how many subscriptions there are in the file
    sublength=$( jq '. | length' < "$yt_sub_import_file" )

    for i in $( seq 0 $((sublength-1)) ); do

        channelInfo=$(jq --argjson index ${i} '[ "https://www.youtube.com/channel/" + .[$index].snippet.resourceId.channelId + "/videos", "#" + .[$index].snippet.title ]' < "$yt_sub_import_file")
	printf "%s\n" "$(printf "%s" "$channelInfo" | tr -d '[]"\n,')" >> "$subscriptions_file"

    done
    exit
}


is_non_number () {
	case $1 in
		(*[!0-9]*|'')
			return 0;;
		(*)
			return 1;;
	esac
}

bad_opt_arg () {
	opt=$1
	arg=$2
	printf "%s\n" "$opt requires a numeric arg, but was given \"$arg\""
	exit 2
}

#OPT
parse_long_opt () {
	opt=$1
	#if the option has a short version it calls this function with the opt as the shortopt
	case ${opt} in
	        help) parse_opt "h" ;;
		help-all)
		    all_help_info
		    exit ;;

		is-ext-menu|is-ext-menu=*)
		    [ "$opt" = "is-ext-menu" ] && parse_opt "D" || parse_opt "D" "${opt#*=}"
		    is_non_number "$is_ext_menu" && bad_opt_arg "--ext-menu=" "$is_ext_menu" ;;

		download) parse_opt "d" ;;

		choose-from-history) parse_opt "H" ;;

		clear-history) parse_opt "x" ;;

		search-again|search-again=*)
		    [ "$opt" = 'search-again' ] && parse_opt "s" || parse_opt "s" "${opt#*=}"
		    is_non_number "$search_again" && bad_opt_arg "--search=" "$search_again" ;;

		loop|loop=*)
		    [ "$opt" = 'loop' ] && parse_opt "l" || parse_opt "l" "${opt#*=}"
		    is_non_number "$YTFZF_LOOP" && bad_opt_arg "--loop=" "$YTFZF_LOOP" ;;

		show-thumbnails|show-thumbnails=*)
		    [ "$opt" = 'show-thumbnails' ] && parse_opt "t" || parse_opt "t" "${opt#*=}"
		    is_non_number "$show_thumbnails" && bad_opt_arg "--thumbnails=" "$show_thumbnails" ;;

		thumbnail-quality=*)
			parse_opt "t"
			thumbnail_quality=${opt#*=}
			is_non_number "$thumbnail_quality" && bad_opt_arg "--thumbnail-quality=" "$thumbnail_quality" ;;

		show-link-only|show-link-only=*)
		    [ "$opt" = 'show-link-only' ] && parse_opt "L" || parse_opt "L" "${opt#*=}"
		    is_non_number "$show_link_only" && bad_opt_arg "--link-only=" "$show_link_only" ;;

		link-count=*) parse_opt "n" "${opt#*=}" ;;

		audio-only) parse_opt "m" ;;

		auto-select|auto-select=*)
		    [ "$opt" = 'auto-select' ] && parse_opt "a" || parse_opt "a" "${opt#*=}"
		    is_non_number "$auto_select" && bad_opt_arg "--auto-play=" "$auto_select" ;;

		select-all|select-all=*)
		    [ "$opt" = 'select-all' ] && parse_opt "A" || parse_opt "A" "${opt#*=}"
		    is_non_number "$select_all" && bad_opt_arg "--select-all=" "$select_all" ;;

		random-select|random-select=*)
		    [ "$opt" = 'random-select' ] && parse_opt "r" || parse_opt "r" "${opt#*=}"
		    is_non_number "$random_select" && bad_opt_arg "--random-play=" "$random_select" ;;

		upload-time=*) upload_date_filter=${opt#*=} ;;
		last-hour|today|this-week|this-month|this-year) upload_date_filter="$opt" ;;

		upload-sort=*) sort_by_filter=${opt#*=} ;;
		upload-date|view-count|rating) sort_by_filter=$opt ;;

		filter-id=*|sp=*) sp=${opt#*=} ;;

		preview-side=*) export PREVIEW_SIDE=${opt#*=} ;;

		update) update_ytfzf "master" ;;
		update-unstable) update_ytfzf "development" ;;

		subs) parse_opt "S" ;;
		subs=*)
			sub_link_count=${opt#*=}
			is_non_number "$sub_link_count" && bad_opt_arg "--subs" "$sub_link_count"
			parse_opt "S"
			;;

		fancy-subs) fancy_subscriptions_menu=1 ;;
		fancy-subs=*) fancy_subscriptions_menu=${opt#*=} ;;

		notification) parse_opt "N" ;;

		version)
		    printf "\033[1mytfzf:\033[0m %s\n" "$YTFZF_VERSION"
		    printf "\033[1myoutube-dl:\033[0m %s\n" "$(youtube-dl --version)"
		    command -v "fzf" 1>/dev/null && printf "\033[1mfzf:\033[0m %s\n" "$(fzf --version)"
		    exit ;;

       		subt)  auto_caption=1 ;;

		trending|trending=*) [ "$opt" = 'trending' ] && parse_opt "T" || parse_opt "T" "${opt#*=}" ;;

		add-subs) create_subs ;;

		sort) sort_videos_data=1 ;;

		*)
		    printf "Illegal option --%s\n" "$opt"
		    usageinfo
		    exit 2 ;;
	esac
	unset opt
}
parse_opt () {
	#the first arg is the option
	opt=$1
	#second arg is the optarg
	optarg=$2
	case ${opt} in
		#Long options
		-)	parse_long_opt "$optarg" ;;
		#Short options
		h) 	basic_helpinfo
			printf "type --help-all for more info\n"
			exit ;;

		D) 	is_ext_menu=${optarg:-1} ;;

		m) 	is_audio_only=1 ;;

		d) 	is_download=1 ;;

		f) 	show_format=1 ;;

		H)	scrape="history" ;;

		x)	clear_history && exit ;;

		a)	auto_select=${optarg:-1} ;;

		A)	select_all=${optarg:-1} ;;

		r)	random_select=${optarg:-1} ;;

		s)	search_again=${optarg:-1} ;;

		S)	scrape="yt_subs" ;;

		T)
		    trending_tab=${optarg:-}
		    scrape="trending" ;;

		l) 	YTFZF_LOOP=${optarg:-1} ;;

		t) 	show_thumbnails=${optarg:-1} ;;

		v)	printf "ytfzf: %s\n" "$YTFZF_VERSION"
			exit ;;

		L) 	show_link_only=${optarg:-1} ;;

		n)
		    link_count="$optarg"
		    is_non_number "$link_count" && bad_opt_arg "-n" "$link_count" ;;

		U) 	[ -p "$FIFO" ] && preview_img "$optarg"; exit;
			# This option is reserved for the script, to show image previews
			# Not to be used explicitly
			;;

		N)	YTFZF_NOTI=1 ;;

		*)
			usageinfo
			exit 2 ;;
	esac
	unset opt optarg
}

while getopts "LhDmdfxHaArltSsvNTn:U:-:" OPT; do
    parse_opt "$OPT" "$OPTARG"
done
shift $((OPTIND-1))

#used for thumbnail previews in ueberzug
if [ $is_ext_menu -eq 0 ]; then
	export TTY_LINES=$(tput lines)
 	export TTY_COLS=$(tput cols)
fi

#if both are true, it defaults to using fzf, and if fzf isnt installed it will throw an error
#so print this error instead and set $show_thumbnails to 0
if [ $is_ext_menu -eq 1 -a $show_thumbnails -eq 1 ]; then
	if ! notify-send "Currently thumbnails do not work in external menus" 1> /dev/null 2>&1; then
	    printf "\033[31mCurrently thumbnails do not work in external menus\033[0m\n"
	fi
	show_thumbnails=0
fi

#if stdin is given and no input (including -) is given, throw error
#also make sure its not reading from ext_menu
if [ ! -t 0 ] && [ -z "$*" ] && [ $is_ext_menu -eq 0 ]; then
	print_error "\033[31mERROR[#04]: Use - when reading from stdin\033[0m\n"
	exit 2
#read stdin if given
elif [ "$*" = "-" ]; then
	printf "Reading from stdin\n"
	while read -r line
	do
	    search_query="$search_query $line"
	done
fi
check_if_url "${search_query:=$*}"

# If in auto select mode dont download thumbnails
[ $auto_select -eq 1 ] || [ $random_select -eq 1 ] && show_thumbnails=0;

#format the menu screen
format_menu


case $scrape in
	"trending")
		scrape_yt ;;
	"yt_search")
		get_search_query
		scrape_yt "$search_query" ;;
	"yt_subs")
		scrape_subscriptions
		;;
	"history")
		get_history
		;;
	"url")
	    play_url
	    exit
	    ;;
	*)
	    printf "\033[31mError: \$scrape set to bad option, set to '$scrape'${c_reset}\n"
	    exit 1 ;;

esac


while true; do
	user_selection
	format_user_selection
	print_data
	get_video_format
	get_sub_lang
	play_url
	save_before_exit

	#if looping and searching_again arent on then exit
	if [ $YTFZF_LOOP -eq 0 ] && [ $search_again -eq 0 ] ; then
		delete_thumbnails
		exit
	fi

	#if -s was specified make another search query
	if [ $search_again -eq 1 ]; then
		search_query=
        	get_search_query
		scrape_yt "$search_query"
	fi
done
