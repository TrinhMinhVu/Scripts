#!/bin/bash
random_line=$(shuf -i0-311 -n1)

# select one rant in a random line, pipe through cowsay and lolcat
jq -r ".[$random_line] | .text" Scripts/linus-rants.json | cowsay -f tux
