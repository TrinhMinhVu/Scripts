#!/bin/bash
all=$(pacman -Qe | cut -d " " -f 1)
echo $all
