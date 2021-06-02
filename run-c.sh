#!/bin/bash
out=$(basename $1 .c)
gcc -std=c99 $1 -o $out -lm && echo -e "\n---\nFile '$1' compiled and is runnning with no error (maybe some warnings lol):\n---" && ./$out || echo -e "\n---\nFile '$1' compiled with errors which are shown above\n---"
