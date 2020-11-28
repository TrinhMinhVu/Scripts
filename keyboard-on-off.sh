#!/bin/bash

xinput list | grep -w "∼ HID 04d9:a088" || exec /home/mx-vu/Scripts/disablekeyboard.sh && exec /home/mx-vu/Scripts/enablekeyboard.sh
