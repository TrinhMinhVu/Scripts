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
echo "vu: $(newmail $vu $vupass) vik: $(newmail $vik $vikpass) fx: $(newmail $fx $fxpass)"
