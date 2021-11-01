#!/usr/bin/env bash

_usage() {
    echo "$(basename "$0") list | scan | reset | setup <ssid>"
    exit 0
}

_err() {
    echo "$1"
    exit 1
}

_check() {
    [ -z "${2:-}" ] && _err "missing $1"
}

_select() {
    _check "SSID" "${1:-}"
    N="$(sudo wpa_cli -i "$INTERFACE" list_networks | grep "$1" | cut -f1)"
    if [ -n "$N" ]
    then sudo wpa_cli -i "$INTERFACE" select_network "$N"
    else _err "no such network"
    fi
}

_list() {
    sudo wpa_cli list_networks | tail -n+3 | cut -f2
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
p2p_disabled=1
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
    sudo systemctl restart wpa_supplicant
}

_remove() {
    _check "SSID" "${1:-}"
    TMP="$(mktemp "/tmp/XXX")"

    if [ -n "$1" ]
    then if awk -v RS="network=" '$2 !~ /ssid="'"$1"'"/{if (0<n) printf "network="; printf $0; n++}' < "$CFG" > "$TMP"
         then sudo mv "$TMP" "$CFG"
         fi
    fi
}

_setup() {
    _check "SSID" "${1:-}"

    [ ! -f "$CFG" ] && _setup_init | sudo tee "$CFG"

    if ! grep -q 'ssid=:"'"$1"'"' "$CFG"
    then read -r -p "password for $1: " -s KEY
         if [ -z "$KEY" ]
         then CONF=$(_no_passphrase "$1")
         else CONF=$(wpa_passphrase "$1" "$KEY" | grep -v "\#")
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
    scan)      _scan;;
    ls|list)   _list;;
    reset)     _reset;;
    "select")  _select "${2:-}";;
    rm|remove) _remove "${2:-}";;
    add|setup) _setup  "${2:-}";;
    *) _usage;;
esac
