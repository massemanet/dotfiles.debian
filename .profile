# one path to rule them all
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
[ -d /opt/bin ] && export PATH=/opt/bin:$PATH
[ -d $HOME/bin ] && export PATH=$HOME/bin:$PATH
[ -d /snap/bin ] && export PATH=/snap/bin:$PATH

# one locale to rule them all
unset  LC_ALL
unset  LANGUAGE
unset  LC_CTYPE
export LANG=$(locale -a | grep -Ei "en.us.utf")
