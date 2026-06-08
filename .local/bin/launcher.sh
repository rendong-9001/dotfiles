#!/bin/sh
set -eu

: "${XDG_SESSION_TYPE:=}"

export BEMENU_OPTS="
 --fn 'Hack 12'
 --nb '#1A2626'
 --nf '#E5E0E0'
 --sb '#8DB6CD'
 --sf '#1A2626'
 --hb '#8DB6CD'
 --hf '#1A2626'
 --tb '#CD3700'
 --tf '#FFFAFA'
 --fb '#1A2626'
 --ff '#7FFF00'
 --bdr '#8DB6CD'
 -W 0.3
 -B 2
 -l 15
"

run_if_exists() {
    if ! command -v "$1" >/dev/null 2>&1; then
        notify-send -u normal "${0##*/}" "Error: $1 is not installed." || :
        exit 1
    fi
    exec "$@"
}

run() {
    case "$XDG_SESSION_TYPE" in
        wayland)
            run_if_exists fuzzel
            ;;
        x11)
            run_if_exists bemenu-run
            ;;
        *)
            notify-send -u critical "${0##*/}" "Error: XDG_SESSION_TYPE must be set to wayland or x11." || :
            exit 1
            ;;
    esac
}

run
