#!/bin/bash
# -*- mode: shell-script -*-
# ~/.bashrc: executed by bash(1) for non-login shells.
#
# debian style

# make scp work by checking for a tty
[ -t 0 ] || return

# clean up
unalias -a

# check terminal resize
shopt -s checkwinsize

# pretty colors
eval "$(dircolors)"

. /etc/bash_completion
# shellcheck disable=SC1090
. <(kubectl completion bash)

# define some git helpers
# shellcheck source=bin/gitfunctions
[ -f ~/bin/gitfunctions ] && . ~/bin/gitfunctions

# aws-vault
export AWS_VAULT_BACKEND=pass
export AWS_VAULT_PASS_PREFIX=masse

# emacs
export EDITOR="emacsclient -ct -a ''"

# PS1
export GIT_PS1_SHOWSTASHSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWDIRTYSTATE=true
export PROMPT_COMMAND='prompt_exit LX; prompt_history ; prompt_sshid'
if [ -f ~/.kube/config ] && test "$(command -v kubectl)" ; then
    PROMPT_COMMAND+="; prompt_k8s"
fi
if [ "$TERM" != "dumb" ]; then
    # set a fancy prompt
    export PS1='\[\e[33m\]\h'
    export PS1+='\[\e[36m\]${SSHID:+[${SSHID}]}'
    export PS1+='\[\e[31m\]${K8S:+{${K8S}\}}'
    export PS1+='\[\e[35m\]($(mygitdir):$(mygitbranch))'
    export PS1+='\[\e[32m\]${LX:+\[\e[31m\]($LX)}$'
    export PS1+='\[\e[0m\] '
else
    export PS1="\\h\\$ "
fi

dir()  { ls -AlFh --color "$@"; }
dirt() { dir -rt "$@"; }
dird() { dir -d "$@"; }
rea()  { history | grep -E "${@:-}"; }
c()    { cat "$@"; }
g()    { grep -nIHE --color "$@"; }
m()    { less "$@"; }

prompt_exit() {
    eval "$1='$?'; [ \$$1 == 0 ] && unset $1"
}

prompt_history() {
    history -a
}

prompt_k8s() {
    local CF CC CL CN
    CF="$(kubectl -o json config view)"
    CC="$(echo "$CF" | jq '."current-context"')"
    CL="$(echo "$CF" | jq -r '.contexts[]|select(.name == '"$CC"').context.cluster' | cut -f2 -d".")"
    CN="$(echo "$CF" | jq -r '.contexts[]|select(.name == '"$CC"').context.namespace')"
    K8S="$CL:$CN"
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

#the below will make all commands visible in all shells
#PROMPT_COMMAND="$PROMPT_COMMAND ; history -a ; history -c; history -r"

# multi-line commands
shopt -s cmdhist

# motd
uname -a
