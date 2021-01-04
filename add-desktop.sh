#!/bin/bash
name="$(echo $1 | cut -d "." -f 1 | cut -d "/" -f 2)"
echo $name

cp ${HOME}/Scripts/notes.desktop ${HOME}/.local/share/applications/$name.desktop
sed -i "4i Exec=$(pwd)/$1" ${HOME}/.local/share/applications/$name.desktop
nvim ${HOME}/.local/share/applications/$name.desktop
