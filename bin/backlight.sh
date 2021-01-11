#!/usr/bin/env bash

if [ -z "$1" ]
then read -r -p "intensity: " I
else I="$1"
fi
echo "$I" | sudo tee "/sys/class/leds/smc::kbd_backlight/brightness"
