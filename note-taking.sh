#!/bin/sh

noteFileName="${HOME}/GhiChu/quicknotes/note-one-for-all.md"

if [ ! -f $noteFileName ]; then
	echo "# Notes one for all" > $noteFileName
fi

nvim -c "norm Go" \
	-c "norm Go ---" \
	-c "norm Go## $(date '+%d/%m/%Y %H:%M')" \
	-c "norm G2o" \
	-c "norm zz" \
	$noteFileName
