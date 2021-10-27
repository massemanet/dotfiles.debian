#!/bin/bash
# -*- mode: shell-script -*-
# ~/.bashrc: executed by bash(1) for non-login shells.
#
# debian style

# make scp work by checking for a tty
[ -t 0 ] || return
[[ "${-}" =~ 'i' ]] || return

# clean up
unalias -a

# check terminal resize
shopt -s checkwinsize

# pretty colors
eval "$(dircolors)"

[[ -r /usr/local/etc/profile.d/bash_completion.sh ]] &&
    . /usr/local/etc/profile.d/bash_completion.sh

# define some git helpers
# shellcheck source=bin/gitfunctions
[ -f ~/bin/gitfunctions ] &&
    . ~/bin/gitfunctions

# emacs
export EDITOR="emacsclient -ct -a ''"

# PS1
export GIT_PS1_SHOWSTASHSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWDIRTYSTATE=true

export PROMPT_COMMAND='prompt_exit LX; prompt_history ; prompt_sshid'

PS1='\[\e[33m\]\h'
PS1+='\[\e[36m\]${SSHID:+[${SSHID}]}'
PS1+='\[\e[31m\]${K8S:+{${K8S}\}}'
PS1+='\[\e[35m\]($(mygitdir):$(mygitbranch))'
PS1+='\[\e[32m\]${LX:+\[\e[31m\]($LX)}$'
PS1+='\[\e[0m\] '

dir()  { ls -AlFh --color "$@"; }
dirt() { dir -rt "$@"; }
dird() { dir -d "$@"; }
rea()  { history | grep -E "${@:-}"; }
c()    { cat "$@"; }
m()    { less "$@"; }

prompt_exit() {
    eval "$1='$?'; [ \$$1 == 0 ] && unset $1"
}

prompt_history() {
    history -a
}

prompt_sshid() {
    SSHID="$(~/bin/sshid)"
}

## history
# unlimited history
export HISTSIZE=
export HISTFILESIZE=

# agglomerate history from multiple shells
export HISTCONTROL="ignoredups"
shopt -s histappend

# multi-line commands
shopt -s cmdhist

# motd
uname -a
