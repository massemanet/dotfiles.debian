#!/usr/bin/env bash

set -euo pipefail

_spotify(){
    local N
    N="$(swaymsg -t get_tree | jq -r 'recurse(.nodes[]?)|recurse(.floating_nodes[]?)|select(.window_properties.class=="Spotify").name')"
    [ "$N" == "Spotify Premium" ] || echo "${N:0:35}"
}

_bat_time() {
    local CHARGE CURRENT ENERGY POWER TIME
    if [ -f /sys/class/power_supply/BAT0/charge_now ]; then
        CHARGE="$(cat /sys/class/power_supply/BAT0/charge_now)"
        CURRENT="$(cat /sys/class/power_supply/BAT0/current_now)"
        [ "$CURRENT" -ne 0 ] && TIME="$(((60*CHARGE)/CURRENT))"
    elif [ -f /sys/class/power_supply/BAT0/energy_now ]; then
        ENERGY="$(cat /sys/class/power_supply/BAT0/energy_now)"
        POWER="$(cat /sys/class/power_supply/BAT0/power_now)"
        [ "$POWER" -ne 0 ] && TIME="$(((60*ENERGY)/POWER))"
    fi
    TIME="${TIME:-0}"
    printf "%2.2u:%2.2u" "$((TIME/60))" "$((TIME%60))"
}

_bat() {
    local STATUS CAPACITY
    STATUS="$(cat /sys/class/power_supply/BAT0/status)"
    CAPACITY="$(cat /sys/class/power_supply/BAT0/capacity)"
    if [ "${1:-""}" = "color" ]; then
        if [ "$STATUS" = "Discharging" ] && ((CAPACITY < 5))
        then echo "#ee1111"
        else echo "11ee11"
        fi
    else
        if [ "$STATUS" = "Discharging" ]
        then echo "${STATUS}[${CAPACITY}%][$(_bat_time)]"
        else echo "${STATUS}[${CAPACITY}%]"
        fi
    fi
}

_net() {
    local T
    T="$(2>/dev/null iwconfig | grep ESSID | cut -f2 -d"\"")"
    [ -n "$T" ] && echo "$T"
}

_ping() {
    local T
    T=$(ping -c1 -W1 8.8.8.8 | grep -Eo "time=[0-9\.]+" | cut -f2 -d"=")
    [ -n "$T" ] && echo "${T}ms"
}

_cpu_color() {
    echo "#eeeeee"
}

_cpu(){
    local CPUS="$1" UP0="$2" IDLE0="$3" UP1="$4" IDLE1="$5"
    echo "$(( (100*(CPUS*(UP0-UP1)-(IDLE0-IDLE1)))/(UP0-UP1) ))%"
}

_date() {
    date +'%Y-%m-%d'
}

_time() {
    date +'%H:%M:%S'
}

_bar() {
    printf '[{"full_text": "%s"}' "$(_spotify)"
    printf ',{"full_text": "%s"}' "$(_net)"
    printf ',{"full_text": "%s"}' "$(_ping)"
    printf ',{"full_text": "%s", "color":"'"$(_cpu_color "$@")"'"}' "$(_cpu "$@")"
    printf ',{"full_text": "%s", "color":"'"$(_bat color)"'"}' "$(_bat)"
    printf ',{"full_text": "%s"}' "$(_date)"
    printf ',{"full_text": "%s"}' "$(_time)"
    echo "],"
}

CPUS="$(grep siblings /proc/cpuinfo | head -n1 | cut -f2 -d":" | tr -d " ")"
U0=(0 0)
echo '{"version": 1}'
echo "["
echo "[],"
while sleep 2
do mapfile -d" " U1 < <(tr -d "." < /proc/uptime)
   _bar "$CPUS" "${U1[@]}" "${U0[@]}"
   U0=("${U1[@]}")
done
