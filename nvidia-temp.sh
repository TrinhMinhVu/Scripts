#!/bin/sh
echo $(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader) 
