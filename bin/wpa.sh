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

_setup_init() {
    cat <<HERE
ctrl_interface=/run/wpa_supplicant
ctrl_interface_group=sudo
update_config=1
HERE
}

_no_passphrase() {
    cat <<HERE
network={
    ssid="$1"
    key_mgmt=NONE
}
HERE
}

_reset() {
    #sudo dhclient -r # release the ip?
    sudo pkill -HUP wpa_supplicant
}

_remove() {
    local SSID="$1"
    TMP="$(mktemp "/tmp/XXX")"

    if [ -n "$SSID" ]
    then if awk -v RS="network=" '$2 !~ /ssid="'"$SSID"'"/{if (0<n) printf "network="; printf $0; n++}' < "$CFG" > "$TMP"
         then sudo mv "$TMP" "$CFG"
         fi
    fi
}

_setup() {
    local SSID="$1"

    [ ! -f "$CFG" ] && echo "$(_setup_init)" | sudo tee "$CFG"

    if ! grep -q 'ssid=:"'"$SSID"'"' "$CFG"
    then read -r -p "password for $SSID: " -s KEY
         if [ -z "$KEY" ]
         then CONF=$(_no_passphrase "$SSID")
         else CONF=$(wpa_passphrase "$SSID" "$KEY" | grep -v "\#")
         fi
         echo "$CONF"
         read -r -p "looks good? (y/n): " KEEP
         [ "$KEEP" = "y" ] || exit 0
         echo "$CONF" | sudo tee -a "$CFG"
    fi
    _reset
}

INTERFACE="$(iw dev | grep Interface  | cut -f2 -d" ")"
CFG="/etc/wpa_supplicant/wpa_supplicant-$INTERFACE.conf"

case "$1" in
    scan)  _scan;;
    list)  _list;;
    reset) _reset;;
    rm)    _remove "$2";;
    setup) _setup "$2";;
    *) _usage;;
esac
