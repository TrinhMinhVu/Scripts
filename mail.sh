#!/bin/bash
newmail () {
	count=$(curl -u $1:$2 --silent "https://mail.google.com/mail/feed/atom" | sed -e "s|.*<fullcount>\(.*\)</fullcount>.*|\1|")
	echo $count
}
vu=
vupass=
vik=
vikpass=
fx=
fxpass=
echo "vu: $(newmail $vu $vupass) vik: $(newmail $vik $vikpass) fx: $(newmail $fx $fxpass)"