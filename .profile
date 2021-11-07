[ -d "$HOME/bin" ] && PATH=$HOME/bin:$PATH

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
