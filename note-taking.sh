#!/bin/sh

noteFileName="${HOME}/GhiChu/quicknotes/note-one-for-all.md"

if [ ! -f $noteFileName ]; then
	echo "# Notes one for all" > $noteFileName
fi

nvim -c "norm Go" \
	-c "norm zz" \
	$noteFileName
