#!/usr/bin/env bash

_brightness() {
    CLASS=/sys/class/backlight/intel_backlight
    if [ -f $CLASS/max_brightness ]
    then read -r MAX < $CLASS/max_brightness
         read -r ACT < $CLASS/brightness
         if [ -z "$1" ]
         then echo $((100*ACT/MAX))%
         else echo $((0 < $1 && $1 <= 100 ? $1*MAX/100 : ACT)) | sudo tee $CLASS/brightness
         fi
    fi
}

# SC complains about weird backslashes
_dark() {
    # shellcheck disable=SC1003
    printf '\x1b]10;#66ff66\x1b\\' && printf '\x1b]11;black\x1b\\'
}

_light() {
    # shellcheck disable=SC1003
    printf '\x1b]10;#586e75\x1b\\' && printf '\x1b]11;#eee8d5\x1b\\'
}

case "${1:-}" in
    dark)                 _dark;;
    light)                _light;;
    [0-9]|[0-9][0-9]|100) _brightness "${1:-}";;
    *)                    echo "$0 [<brightness> | dark | light]"
esac
