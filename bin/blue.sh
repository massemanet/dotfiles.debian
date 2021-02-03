#!/usr/bin/env bash

_usage() {
    echo "$(basename "$0") info | paired | scan [name] | pair [name] | connect [name]"
}

_restart() {
    sudo systemctl restart bluetooth.service
}

_connect() {
    local D
    D="$(bluetoothctl paired-devices | grep "$1" | awk '{print $2}')"
    if [ -z "$D" ]
    then echo "not found"
    else bluetoothctl connect "$D"
    fi
}

_info() {
    (bluetoothctl info 2>/dev/null || true) | grep -E "Name:|Paired:|Connected:" || true
}

_pair() {
    local D
    D=$(_scan "$1")
    if [ -z "$D" ]
    then echo "not found"
    else bluetoothctl pair "$D"
    fi
}

_paired() {
    bluetoothctl paired-devices | cut -c25-
}

_scan() {
    bluetoothctl --timeout 7 scan on >/dev/null
    if [ -z "$1" ]; then
        for D in $(bluetoothctl devices | awk '{print $2}')
        do bluetoothctl info "$D" | grep Name
        done
    else
        bluetoothctl devices | grep "$1" | awk '{print $2}'
    fi
}

case ${1:-""} in
    scan) _scan "${2:-""}";;
    pair) _pair "${2:-""}";;
    connect) _connect "${2:-""}";;
    paired) _paired;;
    info) _info;;
    restart) _restart;;
    *) _usage;;
esac
