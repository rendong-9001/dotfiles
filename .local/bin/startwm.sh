#!/bin/sh
set -eu

: "${XDG_SESSION_TYPE:=wayland}"
: "${XDG_CURRENT_DESKTOP:=niri}"

: "${XDG_RUNTIME_DIR:=/run/user/$(id -u)}"
: "${DBUS_SESSION_BUS_ADDRESS:=unix:path=$XDG_RUNTIME_DIR/bus}"

usage() {
    cat >&"$1" <<EOF
Usage: ${0##*/} [OPTION]

Options:
  -h                Show this help message and exit
  -t                Set XDG_SESSION_TYPE
  -D                Set XDG_CURRENT_DESKTOP (e.g., river, niri)
  -w                Start windows VM (single gpu passthrough)

Examples:
  ${0##*/} -t wayland -D river
  ${0##*/} -h
EOF
    exit "$2"
}

parse_args() {
    while getopts 'ht:D:w' opt; do
        case "$opt" in
            h)
                usage 1 0
                ;;
            t)
                XDG_SESSION_TYPE="$OPTARG"
                ;;
            D)
                XDG_CURRENT_DESKTOP="$OPTARG"
                ;;
            w)
                GUEST_NAME='win10'
                ;;
            ?)
                usage 2 1
                ;;
        esac
    done
    shift $((OPTIND - 1))
}

set_env() {
    # shellcheck source=/dev/null
    [ -f "$HOME/.profile" ] && . "$HOME/.profile"
    export XDG_SESSION_TYPE XDG_CURRENT_DESKTOP
}

mk_dirs() {
    mkdir -p \
        "$HOME/.local/bin" \
        "${XDG_CACHE_HOME:-$HOME/.cache}" \
        "${XDG_CONFIG_HOME:-$HOME/.config}" \
        "${XDG_DATA_HOME:-$HOME/.local/share}" \
        "${XDG_STATE_HOME:-$HOME/.local/state}"
}

start_wm() {
    set_env
    mk_dirs
    # Reuse existing D-Bus session if active, otherwise spawn a new one
    if dbus-send --bus="$DBUS_SESSION_BUS_ADDRESS" / org.freedesktop.DBus.Peer.Ping >/dev/null 2>&1; then
        exec "$@"
    fi
    exec dbus-run-session -- "$@"
}

start_shell() {
    if command -v bash >/dev/null 2>&1; then
        exec bash -l
    fi
    exec sh -l
}

start_vm() {
    if [ -n "${GUEST_NAME:-}" ]; then
        exec virsh -c qemu:///system start "$GUEST_NAME"
    fi
}

# Main routing based on session type and desktop environment
run() {
    start_vm

    case "${XDG_SESSION_TYPE}::${XDG_CURRENT_DESKTOP}" in
        wayland::river)
            start_wm river
            ;;
        wayland::niri)
            start_wm niri --session
            ;;
        x11::*)
            start_wm startx
            ;;
        *)
            start_shell
            ;;
    esac
}

parse_args "$@"
run
