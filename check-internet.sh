#!/bin/bash
nc -z 8.8.8.8 53  >/dev/null 2>&1
online=$?
echo -n $online
