#!/bin/sh
set -eu

: "${XDG_CURRENT_DESKTOP:=}"

wm_env() {
	export WALLPAPER_INTERVAL=1800 # 30min
}

start_wm() {
	wm_env
	if command -v turnstiled >/dev/null 2>&1; then
		exec "$@"
	fi
	exec dbus-run-session "$@"
}

start_shell(){
	if command -v bash >/dev/null 2>&1; then
		exec bash -l
	fi
	exec sh
}

case "$XDG_CURRENT_DESKTOP" in
	river)
		start_wm river
		;;
	niri)
		start_wm niri
		;;
	*)
		start_shell
		;;
esac
