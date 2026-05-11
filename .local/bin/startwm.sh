#!/bin/sh
set -eu

: "${XDG_SESSION_TYPE:=wayland}"
: "${XDG_CURRENT_DESKTOP:=river}"

: "${XDG_RUNTIME_DIR:=/run/user/$(id -u)}"
: "${DBUS_SESSION_BUS_ADDRESS:=unix:path=$XDG_RUNTIME_DIR/bus}"

usage() {
	cat << EOF
Usage: ${0##*/} [OPTION]

Options:
  -h                Show this help message and exit
  -t                Set XDG_SESSION_TYPE
  -D                Set XDG_CURRENT_DESKTOP (e.g., river, niri)

Examples:
  ${0##*/} -t wayland -W river
  ${0##*/} -h
EOF
}

while getopts "ht:D:" opt; do
	case "$opt" in
		h) usage
			exit 0
			;;
		t) XDG_SESSION_TYPE="$OPTARG"
			;;
		D) XDG_CURRENT_DESKTOP="$OPTARG"
			;;
		*) exit 1
			;;
	esac
done

shift $((OPTIND - 1))

set_env() {
	if [ -f "$HOME/.profile" ]; then
		. "$HOME/.profile"
	fi
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
	if dbus-send --bus="$DBUS_SESSION_BUS_ADDRESS" / org.freedesktop.DBus.Peer.Ping >/dev/null 2>&1; then
		exec "$@"
	fi
	exec dbus-run-session -- "$@"
}

start_shell() {
	mk_dirs
	if command -v bash >/dev/null 2>&1; then
		exec bash -l
	fi
	exec sh -l
}

if [ "$XDG_SESSION_TYPE" = wayland ]; then
	case "$XDG_CURRENT_DESKTOP" in
		river)
			start_wm river
			;;
		niri)
			start_wm niri --session
			;;
		*)
			start_shell
			;;
	esac
elif [ "$XDG_SESSION_TYPE" = x11 ]; then
	start_wm startx
else
	start_shell
fi
