#!/usr/bin/env bash

set -euo pipefail

WINS="$(swaymsg -t get_tree | jq -r 'recurse(.nodes[]?)|recurse(.floating_nodes[]?)|select(.type=="con"),select(.type=="floating_con")|select(.nodes==[])|{name: (.app_id // .window_properties.class), id: .id}')"
WIN="$(echo "$WINS" | jq -r .name | rofi -dmenu)"||true
if [ -n "$WIN" ] ; then
    ID="$(echo "$WINS" | jq '.|select(.name == "'"$WIN"'")|.id')"
    swaymsg [con_id="$ID"] focus
fi
