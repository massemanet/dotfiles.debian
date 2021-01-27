#!/usr/bin/env bash

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
    _connect
}

_connect() {
    sudo wpa_supplicant -B -i "$INTERFACE" -c "$CFG"
    sudo dhclient "$INTERFACE"
}

_reset() {
    #sudo dhclient -r # release the ip?
    sudo killall -HUP wpa_supplicant
}

_open() {
    ## – Connecting to open network
    sudo iw dev "$INTERFACE" connect "$SSID"
}

INTERFACE="$(iw dev | grep Interface  | cut -f2 -d" ")"
CFG="/etc/wpa_supplicant/wpa_supplicant-$INTERFACE.conf"

case $1 in
    open) _open "$1";;
    reset) _reset;;
    "") _connect;;
    *) _setup "$1";;
esac
