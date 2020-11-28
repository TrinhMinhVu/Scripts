#!/bin/bash
file='/sys/class/backlight/acpi_video0/brightness'
huh=$(cat $file);
max=1;
if [ $huh -ge $max ];
then
after=$(($huh-1));
exec echo $after > $file;
else exec notify-send 'rock bottom' -t 1000
fi
