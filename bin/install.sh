#!/usr/bin/env bash

set -euo pipefail

_chromium() {
    local GH="https://github.com/NeverDecaf/chromium-web-store/releases"
    local RE="download/v[0-9\\.]+/[a-zA-Z0-9\\.]+crx"
    local r

    brew install eloston-chromium
    r="$(curl -sSL "$GH" | grep -Eo "$RE" | sort -Vu | tail -n1)"
    echo "found file $r"
    mkdir -p ~/.local/chromium-web-store
    curl -sSL "$GH/$r" > ~/.local/chromium-web-store/chromium-web-store.crx
    (cd ~/.local/chromium-web-store && unzip chromium-web-store.crx) || true
    mkdir -p ~/tmp
    ln -s ~/.local/chromium-web-store ~/tmp
    echo "Add the extension in chromium; 'More Tools => Extensions => load unpacked' = /tmp/chromium-web-store"
    echo "Also visit; chrome://flags/#extension-mime-request-handling and set to 'Always prompt...'"
    echo "This is also good; chrome://extensions/shortcuts"
}

case "${1:-}" in
    chromium) _chromium;;
    *) _err "unknown target: ${1:-}";;
esac
