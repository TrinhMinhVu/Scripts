#!/bin/bash
#[ $(ibus engine) = 'xkb:us::eng' ] && echo "eng" ||  [ $(ibus engine) = 'xkb:us::vie' ] && echo "vie" || echo "off"

case $(ibus engine) in
	"xkb:us::eng")
		echo "Eng"
		;;
	"Bamboo")
		echo "Vie"
		;;
	*)
		echo "off"
		;;
esac

exit 0