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

run_by_xdg_session_type() {
	if [ "$XDG_SESSION_TYPE" = wayland ]; then
		exec fuzzel
	elif [ "$XDG_SESSION_TYPE" = x11 ]; then
		exec bemenu-run
	else
		notify-send -u critical "launcher.sh" "XDG_SESSION_TYPE must be set to wayland or x11." || :
		exit 1
	fi
}

run_by_xdg_session_type
