#!/bin/sh

: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"

mkdir -p "$XDG_CACHE_HOME/snooze"

snooze -w 1 -s 7d -t "$XDG_CACHE_HOME/snooze/weekly" -- \
    sh -c \
    "test -d $XDG_CONFIG_HOME/snooze && run-parts --lsbsysinit $XDG_CONFIG_HOME/snooze; touch $XDG_CACHE_HOME/snooze/weekly"
