#!/bin/bash
res=`links2 -dump https://laohac.aternos.me/ | grep "Online"`
if [ res='   This server is currently Online
' ]
then
echo "Server dang bat"
else
echo "Server dang tat"
fi
