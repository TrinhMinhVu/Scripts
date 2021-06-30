#!/bin/sh
# TODO: multisel

target="$1"
[ -z "$target" ] && target="$(realpath .)"
prompt="$2"

while true; do
	p="$prompt"
	[ -z "$p" ] && p="$target"
	sel="$(echo -e "../\n.new\n$(ls -1 "$target" | grep -v '^\.$')" | dmenu -p "$p" -l 25 -i)"
	ec=$?
	[ "$ec" -ne 0 ] && exit $ec

	c="$(echo "$sel" |cut -b1)"
	if [ "$c" = "/" ]; then
		newt="$sel"
	elif [ "$sel" = ".new" ]; then
		n=$(echo "" | dmenu -p "Name?")
		fod=$(echo -e "File\nDirectory" | dmenu -p "File or Directory")
		if [ "$fod" = "File" ]; then
			if [ ! -f "$p/$n" ]; then touch "$p/$n"; else dunstify "File $n already exist"; fi
		elif [ "$fod" = "Directory" ]; then
			if [ ! -d "$p/$n" ]; then mkdir "$p/$n"; else dunstify "Directory $n already exist"; fi
		else
			newt="$p"
		fi
	elif [ "$sel" = "../" ]; then
		newt="$target/../"
	else
		newt="$(realpath "${target}/${sel}")"
	fi
	if [ -e "$newt" ]; then
		target="$newt"
		if [ ! -d "$target" ]; then
			case "$target" in
				*.pdf | *.epub | *.mobi )
					echo "$target" > ~/.local/last-read-book
					zathura "$target" &
					;;
				*)
					xfce4-terminal -e "nvim '${target}'" &
					;;
			esac
			exit 0;
		fi
	fi
done
