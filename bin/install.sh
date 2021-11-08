#!/usr/bin/env bash

set -euo pipefail

usage() {
    echo "$0 TARGET [VSN]"
    err ""
}

err() {
    echo "$1"
    exit 1
}

_check() {
    [ -n "$(2>/dev/null "$1" --version)"]
}

_sort() {
    case "$1" in
        otp) sort -V -t"/" -k3;;
        *) sort -uV;;
    esac
}

_tarball() {
    NAME="$1"
    URL="$2"
    CONFIG="${3:-}"

    mkdir -p ~/tmp
    cd ~/tmp
    [ ! -f "$NAME" ] &&
        curl -sL "$URL" -o "$NAME" &&
        tar -xf "$NAME"
    cd "$(ls -1 | grep -E "$NAME[_-]")"
    ./configure --prefix="$HOME/gnu" "$CONFIG"
    make install
}

_gnu() {
    local NAME="$1"
    local VSN="${2:-latest}"
    local CONFIG="${3:-}"
    local URL="https://ftp.gnu.org/gnu/$TARGET/$TARGET-$VSN.tar.gz"

    _tarball "$NAME" "$URL" "$CONFIG"
}
    
_github() {
    local USER="$1"
    local REPO="$2"
    local VSN="${3:-}"
    local CONFIG="${4:-}"
    local RE="${5:-"download/[0-9\.]+/$REPO-[0-9\.]+[a-z\.]+z"}"
    local DLPAGE="https://github.com/$USER/$REPO/releases"
    
    r="$(curl -sL "$DLPAGE" | grep -oE "$RE" | grep "$VSN" | _sort "$REPO" | tail -n1)"
    [ -z "$r" ] && err "no file at $DLPAGE."
    echo "found file: $r"
    _tarball "$REPO" "$DLPAGE/$r" "$CONFIG"
}

get-autoconf() {
    echo "autoconf"
    _check autoconf || _gnu autoconf
}

get-m4() {
    echo "m4"
    _check m4 || _gnu m4
}

get-make() {
    echo "make"
    _check make || _gnu make 4.3
}

# emacs
get-emacs() {
    echo "emacs"
    get-make
    get-autoconf
    _check emacs || _gnu emacs 27.2 "--without-all"
}

# erlang
get-erlang() {
    local VSN="${1:-}"
    local CONFIGS="--without-javac --without-wx --without-diameter --without-eldap --without-et --without-ftp --without-megaco --without-observer --without-odbc --without-snmp --without-tftp"

    get-make
    get-autoconf

    _github erlang otp "$VSN" "$CONFIGS" 'download/OTP-[0-9\.]+/otp_src_[^"]+z'
}

get-redbug() {
    cd ~/git
    ( [ -d redbug ] || git clone https://github.com/massemanet/redbug )
    cd redbug
    git pull --ff-only
    make
}

get-bash_completion() {
    _github scop bash-completion
}

get-rebar() {
    local VSN="${1:-}"
    _github erlang rebar3 "$VSN"
}

get-tree() {
    local URL="http://mama.indstate.edu/users/ice/tree/src/tree-1.8.0.tgz"
    _tarball tree "$URL"
}

get-rust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/rust.sh
    chmod +x /tmp/rust.sh
    /tmp/rust.sh --no-modify-path -y -q
}

[ -z "$1" ] && usage
TRG="$1"
VSN="${2:-}"
"get-$TRG" "$VSN"
