#!/usr/bin/env bash

set -euo pipefail

err() {
    echo "$1:-"""
    exit 4
}

OTP=~/git/otp
ERL="$(readlink -f "${1:-~/git/loltel/connectivity/erlang}")"

[ -f "$ERL/rebar.config" ] || err "not a rebar project: $1"

cd "$OTP"
rm -f TAGS
for P in lib/*/{src,include} erts/preloaded
do find "$P" -name "*.[he]rl" -print
done | etags -
echo "etagged $OTP"

cd "$ERL"
rebar3 compile || true
rm -f TAGS
for P in src include apps/* _build/default/lib/*
do [ -d "$P" ] && find "$P" -name "*.[he]rl" -print
done | etags -i "$OTP"/TAGS -
echo "etagged $ERL"
