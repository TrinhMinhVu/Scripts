#!/bin/bash
file='/sys/class/backlight/acpi_video0/brightness'
huh=$(cat $file);
max=19;
if [ $huh -le $max ];
then
after=$(($huh+1));
exec echo $after > $file; 
else exec notify-send 'all the way up' -t 1000
fi
