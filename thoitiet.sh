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
		curl wttr.in/${diaDanh[$2]}
	else curl wttr.in/
	fi
	;;
*)
	curl wttr.in/${diaDanh[$1]}?n
	;;
esac
else curl wttr.in/?n
fi
exit 0