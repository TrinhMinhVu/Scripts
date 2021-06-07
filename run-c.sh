#!/bin/bash
out=$(basename $1 .c)
if [ -n "$(grep "\#include <math.h>" $1 )" ]; then
	gcc -std=c99 $1 -o $out -lm \
		&& echo -e "\n---\nFile '$1' compiled and is runnning with no error (maybe some warnings lol):\n---" \
		&& ./$out \
		|| echo -e "\n---\nFile '$1' compiled with errors which are shown above\n---"
else
	gcc -std=c99 $1 -o $out \
		&& echo -e "\n---\nFile '$1' compiled and is runnning with no error (maybe some warnings lol):\n---" \
		&& ./$out \
		|| echo -e "\n---\nFile '$1' compiled with errors which are shown above\n---"
fi
