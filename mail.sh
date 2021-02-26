#!/bin/bash
newmail () {
	 count=$(curl -u $1:$2 --silent "https://mail.google.com/mail/feed/atom")
         echo $count | sed -e "s|.*<fullcount>\(.*\)</fullcount>.*|\1|"
}
vu=
vupass=
vik=
vikpass=
fx=
fxpass=

num=$(($(newmail $vu $vupass)+$(newmail $vik $vikpass)+$(newmail $fx $fxpass)))

if [ $num -eq 0 ]; then
	echo "$num mail" > $HOME/.local/mail-count
elif [ $num -gt 0 ]; then
	echo "$num mail" > $HOME/.local/mail-count
	notify-send -t 2000 "New mail!"
else
	echo "?" > $HOME/.local/mail-count
fi

exit 0
