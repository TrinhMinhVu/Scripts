#!/bin/bash
curl -s $(curl -s https://xkcd.com/$(shuf -i 1-$(curl -s https://xkcd.com/info.0.json | jq -r '.num') -n 1)/info.0.json | jq -r '.img') -o /home/mx-vu/.local/xkcd.png && feh /home/mx-vu/.local/xkcd.png
