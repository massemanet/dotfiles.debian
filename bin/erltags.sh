#!/usr/bin/env bash

set -euo pipefail

OTP=~/git/otp
ERL=~/git/loltel/connectivity/erlang

cd "$OTP"
rm -f TAGS
for P in lib/*/{src,include} erts/preloaded
do find "$P" -name "*.[he]rl" -print
done | etags -

cd "$ERL"
rebar3 compile
rm -f TAGS
for P in src include apps/* _build/default/lib/*
do find "$P" -name "*.[he]rl" -print
done | etags -i "$OTP"/TAGS -
