#!/usr/bin/env bash

_setup() {
    local SSID="$1"

    if [ ! -f "$CFG" ]
    then cat | sudo tee "$CFG" <<HERE
ctrl_interface=/run/wpa_supplicant
update_config=1
HERE
    fi

    read -r -p "password for $SSID: " -s KEY
    CONF=$(wpa_passphrase "$SSID" "$KEY" | grep -v "\#")

    echo "$CONF"
    if ! grep -q "$CONF" "$CFG"
    then read -r -p "looks good? (y/n):" KEEP
         [ "$KEEP" = "y" ] || exit 0
         echo "$CONF" | sudo tee "$CFG"
    fi
    _connect
}

_connect() {
    sudo wpa_supplicant -B -i "$INTERFACE" -c "$CFG"
    sudo dhclient "$INTERFACE"
}

_reset() {
    sudo killall -HUP wpa_supplicant
}

INTERFACE="$(iw dev | grep Interface  | cut -f2 -d" ")"
CFG="/etc/wpa_supplicant/wpa_supplicant-$INTERFACE.conf"

case $1 in
    reset) _reset;;
    "") _connect;;
    *) _setup "$1";;
esac
