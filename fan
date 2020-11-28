#!/bin/bash
if [ -z $1 ]
then
#echo 'ko co gi'
mono /opt/nbfc/nbfc.exe status
else
#echo 'co gi'
mono /opt/nbfc/nbfc.exe $@
fi
