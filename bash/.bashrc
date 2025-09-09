# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# rust 
. "$HOME/.cargo/env" 
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
# alias
alias cal='cal --monday'
alias ls='ls --color=auto'
alias ll='ls -ahl --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias nnn='nnn -e'
alias ping='ping -c 5'
# PS1='[\u@\h \W]\$ '
export PS1='\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[36m\]\[\e[0m\]\n# '
export EDITOR=hx
export PAGER=less
export TERM=xterm-256color
export CDPATH="~/Work"
# nnn
export NNN_OPENER="$HOME/.config/nnn/plugins/opener"
export NNN_BMS="u:$HOME;c:$HOME/.config"
export NNN_PLUG="v:preview-tui"
# fcitx5
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export SDL_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
# bash_
if [[ -f '/usr/share/bash-completion/bash_completion' ]]; then
    . /usr/share/bash-completion/bash_completion
fi
shopt -s cdspell
shopt -s dirspell
shopt -s histappend
shopt -s checkwinsize
shopt -s extglob
export HISTFILE="$HOME/.local/state/bash_history"
export LESSHISTFILE="$HOME/.local/state/less_history"
export HISTSIZE=5000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedup:ignoreboth
export PROMPT_COMMAND="history -a"
# runit
export SVDIR="$HOME/.config/service"
export SVWAIT=5
# git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gd='git diff'
