#!/bin/sh
pandoc -f markdown $1 \
	--pdf-engine=xelatex\
	--metadata-file=/home/mx-vu/.config/pandoc/yaml.yaml\
	--highlight-style=tango\
	-o $1.pdf
