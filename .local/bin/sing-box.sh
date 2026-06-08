#!/bin/sh

: "{XDG_STATE_HOME:=$HOME/.local/state}"
: "{XDG_CONFIG_HOME:=$HOME/.config}"

mkdir -p \
    "$XDG_STATE_HOME/sing-box" \
    "$XDG_CONFIG_HOME/sing-box"

sing-box run \
    -D "$XDG_STATE_HOME/sing-box" \
    -C "$XDG_CONFIG_HOME/sing-box"
