#!/bin/bash
echo "CPU: $(($(head /sys/devices/platform/coretemp.0/hwmon/hwmon2/temp1_input)/1000))°C; GPU: $(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader)°C"
