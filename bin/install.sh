#!/bin/bash

set -euo pipefail

usage() {
    echo "$0 TARGET [VSN]"
    err ""
}

err() {
    echo "$1"
    exit 1
}

get-aws-vault() {
    local r
    local VSN="${1:-}"
    local DLPAGE="https://github.com/99designs/aws-vault/releases"
    local RE="download/v[0-9\\.]+/aws-vault-linux-amd64"

    r="$(curl -sL "$DLPAGE" | grep -oE "$RE" | grep "$VSN" | sort -uV | tail -n1)"
    [ -z "$r" ] && err "no file at $DLPAGE."
    echo "found file: $r"
    curl -sL "$DLPAGE/$r" -o /tmp/aws-vault
    sudo install /tmp/aws-vault /usr/bin
}

get-awscli() {
    sudo apt-get update &&
        sudo apt-get install -y --auto-remove \
             awscli
}

get-bazel() {
    local VSN="${1:-}"
    local GH="https://github.com/bazelbuild/bazel/releases"
    local RE="download/[.0-9-]+/bazel-[.0-9-]+-installer-linux-x86_64.sh"
    local r

    sudo apt-get update &&
        sudo apt-get install -y --auto-remove \
             unzip
    r="$(curl -sSL "$GH" | grep -Eo "$RE" | grep "$VSN" | sort -Vu | tail -n1)"
    echo "found file $r"
    curl -sSL "$GH/$r" > /tmp/bazel.sh
    chmod +x /tmp/bazel.sh
    sudo /tmp/bazel.sh
    sudo rm -f /etc/bash_completion.d/bazel-complete.bash
    sudo ln -s /usr/local/lib/bazel/bin/bazel-complete.bash /etc/bash_completion.d
}

get-bazelisk() {
    local VSN="${1:-}"
    local GH="https://github.com/bazelbuild/bazelisk/releases"
    local RE="download/v[.0-9-]+/bazelisk-linux-amd64"
    local r

    r="$(curl -sSL "$GH" | grep -Eo "$RE" | grep "$VSN" | sort -Vu | tail -n1)"
    echo "found file $r"
    curl -sSL "$GH/$r" > /tmp/bazelisk
    chmod +x /tmp/bazelisk
    cp /tmp/bazelisk ~/bin/bazel
}

get-brave(){
    curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc |\
        sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
    echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
        sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update &&
        sudo apt install -y --auto-remove \
             brave-browser
}

get-chromium() {
    local v r
    local GH="https://github.com/Eloston/ungoogled-chromium-binaries/releases"

    r="$(curl -sSL "$GH")"
    v="$(echo "$r" | grep -Eo "download/[^/]+unportable[^/]+" | sort -u)"
    r="$(echo "$r" | grep -Eo "$v/ungoogled-chromium.*_amd64.deb" | grep -Ev "driver|dbgsym")"
    for v in $r
    do echo "found file $v"
       curl -sSL "$GH/$v" > /tmp/$$
       sudo dpkg -i /tmp/$$
    done

    local GH="https://github.com/NeverDecaf/chromium-web-store/releases"
    local RE="download/v[0-9\\.]+/[a-zA-Z0-9\\.]+crx"
    r="$(curl -sSL "$GH" | grep -Eo "$RE" | grep "$VSN" | sort -Vu | tail -n1)"
    echo "found file $r"
    mkdir -p ~/.local/chromium-web-store
    curl -sSL "$GH/$r" > ~/.local/chromium-web-store/chromium-web-store.crx
    (cd ~/.local/chromium-web-store && unzip chromium-web-store.crx) || true
    ln -s ~/.local/chromium-web-store /tmp
    echo "Add the extension in chromium; 'More Tools => Extensions => load unpacked' = /tmp/chromium-web-store"
    echo "Also visit chrome://flags/#extension-mime-request-handling and set to 'Always prompt...'"
}

get-docker() {
    local r s

    B="https://download.docker.com/linux/debian/dists/buster/pool/test/amd64"
    r="$(curl -sSL "$B")"
    for s in containerd.io docker-ce-cli docker-ce
    do RE="${s}_[^_]*_amd64.deb"
       S="$(echo "$r" | grep -Eo "$RE" | sort -urV | head -n 1)"
       echo "$S"
       curl -sSL "$B/$S" > /tmp/$$
       sudo dpkg -i /tmp/$$
    done

    groups | grep docker || sudo adduser "$USER" docker

    local GH="https://github.com/docker/docker-credential-helpers/releases"
    local RE="download/v[0-9\\.]+/docker-credential-pass-v[0-9\\.]+-amd64.tar.gz"
    r="$(curl -sSL "$GH" | grep -Eo "$RE" | grep "$VSN" | sort -Vu | tail -n1)"
    echo "found file $r"
    curl -sSL "$GH/$r" > /tmp/docker_cred_helper.tgz
    rm -rf ~/pet/docker
    mkdir -p ~/pet/docker
    mkdir -p ~/.docker
    tar -C ~/pet/docker -xzf /tmp/docker_cred_helper.tgz
    chmod +x ~/pet/docker/docker-credential-pass
    echo '{"credsStore": "pass"}' > ~/pet/docker/config.json
    (cd ~/bin; ln -s ../pet/docker/docker-credential-pass . ; cd ~/.docker ; ln -s ../pet/docker/config.json .)
}

get-docker-compose() {
    local r
    local VSN="${1:-}"
    local DLPAGE="https://github.com/docker/compose/releases"
    local RE="download/[0-9\\.]+/docker-compose-Linux-x86_64"

    r="$(curl -sL "$DLPAGE" | grep -oE "$RE" | grep "$VSN" | sort -uV | tail -n1)"
    [ -z "$r" ] && err "no file at $DLPAGE."
    echo "found file: $r"
    sudo curl -sL "$DLPAGE/$r" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

# emacs for wayland
get-emacs() {
    cd /tmp
    [ -d emacs ] || git clone --depth=2 --single-branch https://github.com/masm11/emacs
    cd emacs/
    ./autogen.sh
    sudo apt update &&
        sudo apt install -y --auto-remove \
             libcairo2-dev libgtk-3-dev libgnutls28-dev libncurses-dev
    ./configure --with-pgtk --with-cairo --with-modules --without-makeinfo
    sudo make install
    [ ! -d ~/.cask ] && \
        curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python
    cd ~/.emacs.d
    ~/.cask/bin/cask install
}

# install erlang + rebar + redbug
get-erlang() {
    local VSN="${1:-23}"

    command -v make > /dev/null || err "install 'make'"
    command -v automake > /dev/null || err "install 'automake'"
    command -v autoconf > /dev/null || err "install 'autoconf'"

    sudo true
    sudo apt update &&
        sudo apt-get install -y --auto-remove \
             libncurses-dev libpcap-dev libsctp-dev libssl-dev libwxgtk3.0-gtk3-dev
    [ -d ~/git/otp ] || git clone --depth=2 --branch "maint-$VSN" --single-branch \
                            https://github.com/erlang/otp.git ~/git/otp
    cd ~/git/otp/
    git pull --depth=2
    ./otp_build autoconf
    ./configure --without-megaco --without-odbc --without-jinterface --without-javac
    make
    sudo make install

    mkdir -p ~/.emacs.d/masserlang \
        && rm -f ~/.emacs.d/masserlang/masserlang.el \
        && ln -s ~/install/masserlang.el ~/.emacs.d/masserlang
    rm -f ~/.erlang \
        && ln -s ~/install/erlang ~/.erlang
    rm -f ~/user_default.erl \
        && ln -s ~/install/user_default.erl ~

    curl https://s3.amazonaws.com/rebar3/rebar3 > /tmp/rebar3
    sudo cp /tmp/rebar3 /usr/local/bin/rebar3
    sudo chmod +x /usr/local/bin/rebar3

    cd ~/git
    ( [ -d redbug ] || git clone https://github.com/massemanet/redbug )
    cd redbug
    make
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

get-gopass() {
    local r TMP
    local VSN="${1:-}"
    local DLPAGE="https://github.com/gopasspw/gopass/releases"
    local RE="download/v[0-9\\.]+/gopass-[0-9\\.]+-linux-amd64.tar.gz"

    TMP="$(mktemp)"
    r="$(curl -sL "$DLPAGE" | grep -oE "$RE" | grep "$VSN" | sort -uV | tail -n1)"
    [ -z "$r" ] && err "no file at $DLPAGE."
    echo "found file: $r"
    curl -sL "$DLPAGE/$r" -o "$TMP"
    sudo tar -xz -C /usr/local/bin --no-same-owner -f "$TMP" gopass
    sudo chmod +x /usr/local/bin/gopass
}

get-grpcurl() {
    local VSN="${1:-}"
    local ITEM=grpcurl
    local DLPAGE="https://github.com/fullstorydev/$ITEM/releases"
    local RE="download/v[0-9\\.]+/${ITEM}_[0-9\\.]+_linux_x86_64.tar.gz"
    local r TMP

    sudo true
    r="$(curl -sL "$DLPAGE" | grep -oE "$RE" | grep "$VSN" | sort -uV | tail -n1)"
    [ -z "$r" ] && err "no file at $DLPAGE."
    echo "found file: $r"
    TMP="$(mktemp)"
    curl -sL "$DLPAGE/$r" -o "$TMP"
    sudo tar -xz -C /usr/local/bin --no-same-owner -f "$TMP" "$ITEM"
    sudo chmod +x /usr/local/bin/"$ITEM"
}

get-gtk-server() {
    local VSN="${1:-}"
    local DLPAGE="http://gtk-server.org/stable"
    local RE="gtk-server-[0-9\\.]+.tar.gz"
    local r

    sudo apt update \
        && sudo apt install -y --auto-remove \
                libcairo2-dev libgtk-3-dev glade
    r="$(curl -sL "$DLPAGE" | grep -oE "$RE" | grep "$VSN" | sort -uV | tail -n1)"
    echo "found $r"
    curl -sSL "$DLPAGE/$r" > /tmp/gtk-server.tgz
    tar -xz -C /tmp/ -f /tmp/gtk-server.tgz
    cd /tmp/gtk-server-*/src
    ./configure
    make && sudo make install
}

get-intellij() {
    sudo snap install intellij-idea-community --classic
}

get-java() {
    sudo apt-get update &&
        sudo apt-get install -y --auto-remove \
             openjdk-8-jdk-headless openjdk-11-jdk-headless openssh-server
    sudo update-java-alternatives -s java-1.8.0-openjdk-amd64
}

get-keybase() {
    (cd /tmp && curl --remote-name https://prerelease.keybase.io/keybase_amd64.deb)
    sudo apt install -y --auto-remove \
         /tmp/keybase_amd64.deb
    run_keybase
}

get-kotlin() {
    local r
    local VSN="${1:-}"
    local DLPAGE="https://github.com/JetBrains/kotlin/releases"
    local RE="download/v[0-9\\.]+/kotlin-native-linux-[0-9\\.]+.tar.gz"
    local TMP=/tmp/kt.tgz

    r="$(curl -sL "$DLPAGE/latest" | grep -oE "$RE" | grep "$VSN" | sort -uV | tail -n1)"
    [ -z "$r" ] && err "no file at $DLPAGE."
    echo "found file: $r"
    curl -sL "$DLPAGE/$r" -o "$TMP"
    sudo rm -rf /opt/kotlin \
        && sudo mkdir /opt/kotlin \
        && sudo tar -xz -C /opt/kotlin --strip-components=1 --no-same-owner -f "$TMP"
}

get-krew() {
    cd "$(mktemp -d)" &&
        curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" &&
        tar zxvf krew.tar.gz &&
        KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/')" &&
        "$KREW" install krew &&
        ln -s ~/.krew/bin/kubectl-krew ~/bin
}

get-ksniff() {
    command -v kubectl || get-kubectl
    kubectl krew > /dev/null || get-krew
    kubectl krew install sniff &&
        ln -s ~/.krew/bin/kubectl-sniff ~/bin
}

get-kubectl() {
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /tmp/kubernetes.list
    sudo mv /tmp/kubernetes.list /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update \
        && sudo apt-get install -y --auto-remove \
                kubectl
    kubectl completion bash > /tmp/kubectl_completion
    sudo cp /tmp/kubectl_completion /etc/bash_completion.d
}

get-pgadmin3() {
    sudo apt-get update \
        && sudo apt-get install -y --auto-remove \
                pgadmin3
}

get-pgadmin4() {
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    sudo apt-get update &&
        sudo apt-get install -y --auto-remove \
             pgadmin4
}

get-python() {
    sudo apt-get update &&
        sudo apt-get install -y python2 python3 &&
        sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1 &&
        sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2
}

get-rust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/rust.sh
    chmod +x /tmp/rust.sh
    /tmp/rust.sh --no-modify-path -y -q
}

get-spotify() {
    curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -
    curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add -
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt-get update &&
        sudo apt-get install -y --auto-remove \
             spotify-client
}

get-steam() {
    sudo dpkg --add-architecture i386 &&
        sudo apt update &&
        sudo apt install xterm libgl1-mesa-dri:i386 libgl1:i386 libc6:i386

    wget -O /tmp/steam.deb http://media.steampowered.com/client/installer/steam.deb &&
        sudo dpkg -i /tmp/steam.deb &&
        sudo apt --fix-broken install
}

get-sway(){
    sudo apt-get update && \
        sudo apt install -y --auto-remove \
             sway swaylock swayidle xwayland slurp grim wl-clipboard fzf wofi
}

get-wireshark() {
    sudo apt-get update &&
        sudo apt-get install -y --auto-remove \
             tshark wireshark
    sudo usermod -aG wireshark "$USER"
}

sudo true
[ -z "$1" ] && usage
TRG="$1"
VSN="${2:-}"
echo "## $TRG:$VSN ##################################################################"
"get-$TRG" "$VSN"
