#!/bin/bash
xinput --list --name-only | grep -w "PixArt USB Optical Mouse" && exec /home/mx-vu/Scripts/decreasemousespeed.sh && exec /home/mx-vu/Scripts/disabletouchpad.sh 
