#!/bin/sh

: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"

mkdir -p \
    "$XDG_STATE_HOME/snooze" \
    "$XDG_CONFIG_HOME/snooze"

exec snooze -w 1 -s 7d -t "$XDG_STATE_HOME/snooze/weekly" -- \
    sh -c \
    "test -d $XDG_CONFIG_HOME/snooze && run-parts --lsbsysinit $XDG_CONFIG_HOME/snooze; touch $XDG_STATE_HOME/snooze/weekly"
