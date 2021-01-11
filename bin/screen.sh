#!/usr/bin/env bash

CLASS=/sys/class/backlight/intel_backlight
if [ -f $CLASS/max_brightness ]; then
    read -r MAX < $CLASS/max_brightness
    read -r ACT < $CLASS/brightness
    if [ -z "$1" ]
    then echo $((100*ACT/MAX))%
    else echo $((0 < $1 && $1 <= 100 ? $1*MAX/100 : ACT)) | sudo tee $CLASS/brightness
    fi
fi
