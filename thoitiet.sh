#!/bin/bash
#khai bao mang associative
declare -A diaDanh
diaDanh[xabang]="10.7254656,107.2426289"
diaDanh[duong18]="10.865062780042448,106.7904976505126"

#them vao boi --add


#case
if [ "$1" != "" ]; then
case "$1" in
"--help")
	echo ${!diaDanh[@]}
	;;
"--add")
	sed -i "8i diaDanh[$2]=\"$3\"" /home/mx-vu/Scripts/thoitiet.sh
	;;
"--full")
	if [ "$2" != "" ]; then
		curl -s wttr.in/${diaDanh[$2]}?lang=vi
	else curl -s wttr.in/?lang=vi
	fi
	;;
"--mini")
	if [ "$2" != "" ]; then
		curl -s wttr.in/${diaDanh[$2]}?format="%t+%C"
	else curl wttr.in/?lang=vi\&format="%t+%C"
	fi
	;;
*)
	curl -s wttr.in/${diaDanh[$1]}?lang=vi\&n
	;;
esac
else curl -s wttr.in/?lang=vi\&n
fi
exit 0
