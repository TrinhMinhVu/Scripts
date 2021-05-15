#!/bin/bash
newmail () {
	curl -u $1:$2 --silent "https://mail.google.com/mail/feed/atom" > /home/mx-vu/.local/newmails-$1
    sed -e "s|.*<fullcount>\(.*\)</fullcount>.*|\1|" /home/mx-vu/.local/newmails-$1
}

#details () {
#	title=$(sed -e "s|.*<title>\(.*\)</title>.*|\1|" /home/mx-vu/.local/newmails-$1)
#	sender=$(sed -e "s|.*<email>\(.*\)</email>.*|\1|" /home/mx-vu/.local/newmails-$1)
#	summary=$(sed -e "s|.*<summary>\(.*\)</summary>.*|\1|" /home/mx-vu/.local/newmails-$1)
#	out="$title $summary\n<u>$sender</u>"
#	echo $out
#}

vu=
vupass=
vik=
vikpass=
fx=
fxpass=


num=$(($(newmail $vu $vupass)+$(newmail $vik $vikpass)+$(newmail $fx $fxpass)))

if [ $num -eq 0 ]; then
	echo " $num" > $HOME/.local/mail-count
elif [ $num -gt 0 ]; then
	echo " $num" > $HOME/.local/mail-count
	notify-send -t 2000 "New mail!"
else
	echo "?" > $HOME/.local/mail-count
fi

exit 0
