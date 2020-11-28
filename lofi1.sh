#!/bin/bash
num=6


case $1 in
	"--add") 
		newnum=$((++num))
		sed -i "2s/.*/num=$newnum/" /home/mx-vu/Scripts/lofi1.sh 
		sed -i "$((num+13))i \"$newnum\"\) exec /home/mx-vu/Scripts/playinparole.sh $2 &;;" /home/mx-vu/Scripts/lofi1.sh
		sed -i "$((num+13+num+6))i \\\t$2" /home/mx-vu/Scripts/lofi1.sh
		;;

#num cong voi dong nay
"1") exec /home/mx-vu/Scripts/playinparole.sh https://www.youtube.com/watch?v=l7TxwBhtTUY &;;
"2") exec /home/mx-vu/Scripts/playinparole.sh https://www.youtube.com/watch?v=5qap5aO4i9A &;;
"3") exec /home/mx-vu/Scripts/playinparole.sh https://www.youtube.com/watch?v=DWcJFNfaw9c &;;
"4") exec /home/mx-vu/Scripts/playinparole.sh https://www.youtube.com/watch?v=5yx6BWlEVcY &;;
"5") exec /home/mx-vu/Scripts/playinparole.sh https://www.youtube.com/watch?v=-5KAN9_CzSA &;;
"6") exec /home/mx-vu/Scripts/playinparole.sh https://www.youtube.com/watch?v=y9L0H3488Ys &;;

#link duoc them vao dong ben tren
	"--help") echo "\"--add url\" to add new lofi stream, \"lofi1.sh number\" to play,  \"--list\" to list links"
		;;
	"--list") 
		echo " 
	https://www.youtube.com/watch?v=l7TxwBhtTUY
	https://www.youtube.com/watch?v=5qap5aO4i9A
	https://www.youtube.com/watch?v=DWcJFNfaw9c
	https://www.youtube.com/watch?v=5yx6BWlEVcY
	https://www.youtube.com/watch?v=-5KAN9_CzSA
	https://www.youtube.com/watch?v=y9L0H3488Ys
	"
	#link duoc them vao echo ben tren
		;;

	*) echo "what chu want $num" ;;
esac
exit 0;