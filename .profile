__path() {
    [ -d "$1" ] && PATH="$1:$PATH"
}
__path "$HOME/bin"
__path "$HOME/gnu/bin"

for f in $HOME/gnu/etc/profile.d/*
do source "$f"
done

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
