#!/usr/bin/env bash

pds() {
   cat <<HERE
/usr/local/opt/grep/libexec/gnubin
/usr/local/opt/coreutils/libexec/gnubin
/usr/local/opt/curl/bin
/usr/local/opt/findutils/libexec/gnubin
/usr/local/opt/gnu-sed/libexec/gnubin
/usr/local/opt/make/libexec/gnubin
/opt/bin
$HOME/bin
$HOME/.cargo/bin
HERE
}

# one path to rule them all
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

for P in $(pds)
do [ -d "$P" ] && PATH="$P:$PATH"
done

eval "$(ssh-agent -s)"
