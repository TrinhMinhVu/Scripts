#!/bin/bash
all=$(pacman -Qet | cut -d " " -f 1)
echo $all