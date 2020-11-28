#!/bin/bash
links=$(youtube-dl --get-url $1)
parole -i $links &

