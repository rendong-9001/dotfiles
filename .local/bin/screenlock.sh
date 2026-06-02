#!/bin/sh
set -eu

: "${XDG_SESSION_TYPE:=}"

run_by_xdg_session_type() {
	if [ "$XDG_SESSION_TYPE" = wayland ]; then
		exec swaylock
	elif [ "$XDG_SESSION_TYPE" = x11 ]; then
		exec slock
	else
		notify-send -u critical "launcher.sh" "XDG_SESSION_TYPE must be set to wayland or x11." || :
		exit 1
	fi
}

run_by_xdg_session_type
