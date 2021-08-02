#!/usr/bin/env bash

_usage() {
    echo "$(basename "$0") list | scan | reset | setup <ssid>"
    exit 0
}

_list() {
    grep "ssid" "$CFG"
}

_scan() {
    sudo iwlist "$INTERFACE" scan | \
        grep "ESSID" | \
        cut -f2- -d":" | \
        grep -Eo '"[a-zA-Z0-9_ -]+"' | \
        sort -u | \
        xargs printf "%s\n"
}

_setup() {
    local SSID="$1"

    if [ ! -f "$CFG" ]
    then cat | sudo tee "$CFG" <<HERE
ctrl_interface=/run/wpa_supplicant
ctrl_interface_group=sudo
update_config=1
HERE
    fi

    if ! grep -q 'ssid=:"'"$SSID"'"' "$CFG"
    then read -r -p "password for $SSID: " -s KEY
         CONF=$(wpa_passphrase "$SSID" "$KEY" | grep -v "\#")
         echo "$CONF"
         read -r -p "looks good? (y/n):" KEEP
         [ "$KEEP" = "y" ] || exit 0
         echo "$CONF" | sudo tee -a "$CFG"
    fi
    _reset
}

_reset() {
    #sudo dhclient -r # release the ip?
    sudo pkill -HUP wpa_supplicant
}

INTERFACE="$(iw dev | grep Interface  | cut -f2 -d" ")"
CFG="/etc/wpa_supplicant/wpa_supplicant-$INTERFACE.conf"

case $1 in
    scan) _scan;;
    list) _list;;
    reset) _reset;;
    setup) _setup "$2";;
    *) _usage;;
esac
