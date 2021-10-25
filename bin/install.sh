
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

# emacs for terminal
get-emacs() {
    local VSN="${1:-28}"

    sudo apt update &&
        sudo apt install -y --auto-remove \
             autoconf texinfo zlib1g-dev libgnutls28-dev libncurses-dev libjansson-dev
    cd ~/git
    [ ! -d emacs ] &&
        git clone --depth 1 --branch "emacs-$VSN" --single-branch git://git.sv.gnu.org/emacs.git
    cd emacs/
    git pull --depth=1 --ff-only
    ./autogen.sh
    ./configure --with-json --with-file-notification=inotify
    sudo make install
}

# install erlang + rebar + redbug
get-erlang() {
    local VSN="${1:-24}"

    command -v make > /dev/null || err "install 'make'"
    command -v automake > /dev/null || err "install 'automake'"
    command -v autoconf > /dev/null || err "install 'autoconf'"

    sudo apt update &&
        sudo apt-get install -y --auto-remove \
             libncurses-dev libssl-dev liblttng-ust-dev

    ## build otp
    [ ! -d ~/git/otp ] &&
        git clone --depth=1 https://github.com/erlang/otp ~/git/otp &&
        cd ~/git/otp &&
        git remote set-branches origin 'maint-*' &&
        git fetch -v
    cd ~/git/otp/
    git co "maint-$VSN"
    git pull --depth=2 --ff-only
    git clean -fdx
    ./configure --without-megaco --without-odbc --without-jinterface --without-javac --disable-sctp --with-dynamic-trace=lttng
    for l in diameter eldap et ftp jinterface megaco mnesia observer odbc  tftp wx xmerl
    do touch lib/$l/SKIP
    done
    make
    sudo make install

    ## build rebar3
    cd ~/git
    git clone https://github.com/erlang/rebar3
    cd rebar3/
    ./bootstrap 
    sudo ln -fs ~/git/rebar3/rebar3 /usr/local/bin/

    ## build redbug
    cd ~/git
    [ ! -d redbug ] &&
        git clone git@github.com:massemanet/redbug
    cd redbug
    git pull --ff-only
    make
}

get-pihole() {
    git clone --depth 1 https://github.com/pi-hole/pi-hole.git pihole
    cd pihole/
    cd automated\ install/
    sudo bash basic-install.sh 
}

get-go() {
    local DL="golang.org/dl"
    local RE="go[0-9]+\.[0-9]+\.[0-9]+\.linux-amd64\.tar\.gz"
    local TGZ

    TGZ="$(curl -sSL "$DL" | grep -Eo "$RE" | sort -rV | head -n1)"
    echo "found $TGZ"
    curl -sSL "$DL/$TGZ" > /tmp/$$.tgz
    sudo tar -C /usr/local -xzf /tmp/$$.tgz
}

get-keybase() {
    (cd /tmp && curl --remote-name https://prerelease.keybase.io/keybase_amd64.deb)
    sudo apt install -y --auto-remove \
         /tmp/keybase_amd64.deb
    sudo apt-get install -f
    run_keybase
}

get-rust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/rust.sh
    chmod +x /tmp/rust.sh
    /tmp/rust.sh --no-modify-path -y -q
}

sudo true
[ -z "$1" ] && usage
TRG="$1"
VSN="${2:-}"
echo "## $TRG:$VSN ##################################################################"
"get-$TRG" "$VSN"
