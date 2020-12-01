#!/bin/bash


newmail () {
	#out="$(curl -u $1:$2 --silent "https://mail.google.com/mail/feed/atom")"
	#name=$out | sed -e "s|.*<name>\(.*\)</name>.*|\1|" 
	#name=$(sed -e "s|.*<name>\(.*\)</name>.*|\1|" <<< $out)
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
#curl -u $username:$password --silent "https://mail.google.com/mail/feed/atom" |  grep -oPm1 "(?<=<title>)[^<]+" | sed '1d'
#echo "$(curl -u $username:$password --silent "https://mail.google.com/mail/feed/atom") | grep -oPm1 "(?<=<title>)[^<]+" | sed '1d'"
