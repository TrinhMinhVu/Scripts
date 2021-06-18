#!/bin/bash
ip link set dev wlp0s20f0u8mon down && macchanger -r wlp0s20f0u8mon && ip link set dev wlp0s20f0u8mon up
