#!/bin/sh
set -eu

: "${XDG_SESSION_TYPE:=}"

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
            run_if_exists swaylock
            ;;
        x11)
            run_if_exists slock
            ;;
        *)
            notify-send -u critical "${0##*/}" "Error: XDG_SESSION_TYPE must be set to wayland or x11." || :
            exit 1
            ;;
    esac
}

run
