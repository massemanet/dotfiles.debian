# one path to rule them all
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
[ -d /opt/bin ] && PATH=/opt/bin:$PATH
[ -d "$HOME/bin" ] && PATH=$HOME/bin:$PATH
[ -d "$HOME/.cargo/bin" ] && PATH="$HOME/.cargo/bin:$PATH"
[ -d "/usr/local/go/bin" ] && PATH="/usr/local/go/bin:$PATH"
[ -d "$HOME/.krew" ] && PATH=$HOME/.krew/bin:$PATH

# one locale to rule them all
unset  LC_ALL
unset  LANGUAGE
unset  LC_CTYPE
L="$(locale -a | grep -Ei "en.us.utf")"
if [ -z "$L" ]; then
    export LANG="C"
else
    export LANG="$L"
fi

eval "$(ssh-agent -s)"
