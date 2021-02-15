#!/bin/bash
currentDir=$(pwd)
if [ -d "$currentDir/$1" ]; then
	cd $1
	#var=$(echo -e "../\n..new\n$(ls -d -g -G --human-readable --group-directories-first *| awk '{ print  $8 "?" $3 "?" substr($1,1,1)  }' | column -t -s  "?")" | rofi -dmenu -theme "~/.cache/wal/colors-rofi-dark.rasi" | awk '{print $1}')
	var=$(echo -e "../\n..new\n$(ls)" | rofi -dmenu | awk '{print $1}')
	
	if [[ "$var" = "../" ]]; then
		rofi-notes.sh $var
	elif [[ "$var" = "..new" ]]; then
		rofi -dmenu | xargs -r -I newfile xfce4-terminal -e "nvim $currentDir/$1/newfile"
	elif [[ "$var" != "" ]]; then
		rofi-notes.sh $var
	fi
elif [ -e $currentDir/$1 ]; then
	#xfce4-terminal -e "/bin/bash nvim $currentDir/$1 "
	

  	#>>	TO LIVE IS TO LEARN	<<
	

	xfce4-terminal -e "nvim $currentDir/$1"
fi



