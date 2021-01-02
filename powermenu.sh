#!/bin/bash
read var
case $var in
	"bspc restart")
	bspc wm -r
	;;
	"bspc logout")
	bspc quit
	;;
	"poweroff")
	sudo -n poweroff
	;;
	"reboot")
	sudo -n reboot
	;;
esac