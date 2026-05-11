# vim: ft=bash noet sw=4 ts=4
# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return;;
esac
# umask
umask 027
# XDG
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
# PS1='[\u@\h \W]\$ '
prompt_status_color() {
	local last_exit_code=$?
	if [ $last_exit_code -eq 0 ]; then
		PS1='\[\e[32m\]\u@\h \[\e[33m\]\w \n\[\e[36m\]$\[\e[0m\] '
	else
		PS1='\[\e[32m\]\u@\h \[\e[33m\]\w \n\[\e[31m\]$\[\e[0m\] '
	fi
}
# editor
export EDITOR=hx
# pager
export PAGER=less
# term
export TERM=xterm-256color
# nnn
export NNN_OPENER="$XDG_CONFIG_HOME/nnn/plugins/opener"
export NNN_BMS="m:/run/media/$USER;e:/etc;c:$XDG_CONFIG_HOME;"
export NNN_PLUG='v:preview-tui'
export NNN_FIFO="$XDG_RUNTIME_DIR/nnn-$UID.fifo"
# bash
shopt -s cdspell
shopt -s dirspell
shopt -s direxpand
shopt -s histappend
shopt -s checkwinsize
shopt -s extglob
CDPATH="$HOME/Work"
HISTFILE="$XDG_STATE_HOME/bash_history"
HISTSIZE=8192
HISTFILESIZE=8192
HISTCONTROL=ignoredups:erasedup:ignoreboth
PROMPT_COMMAND='prompt_status_color; history -a'
# runit
export SVDIR="$XDG_CONFIG_HOME/service"
export SVWAIT=5
# less
export LESSHISTFILE="$XDG_STATE_HOME/less_history"
export LESS="-R -g -w --use-color -DWc -DEm -DPy -Dd+y -Du+g"
# xon/xoff
stty -ixon
# alias
[ -f "$HOME/.bash_aliases" ] && . "$HOME/.bash_aliases"
# tmux
export TMUX_TMPDIR="$XDG_RUNTIME_DIR"
# rust
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
export RUSTUP_DIST_SERVER='https://rsproxy.cn'
export RUSTUP_UPDATE_ROOT='https://rsproxy.cn/rustup'
# keychain
[ -f "$HOME/.keychain/$HOSTNAME-sh" ] && . "$HOME/.keychain/$HOSTNAME-sh"
# pass
export PASSWORD_STORE_CLIP_TIME=60
export PASSWORD_STORE_DIR="$XDG_CONFIG_HOME/password-store"
