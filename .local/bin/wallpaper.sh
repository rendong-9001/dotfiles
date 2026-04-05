#!/bin/sh
set -eu

cd "$(dirname $0)"

. "./utils.sh"

random_sleep 1 3

. "$HOME/.config/wallpaper/config"

WALLPAPER_INTERVAL=${WALLPAPER_INTERVAL:-3600}
WALLPAPER_DIR=${WALLPAPER_DIR:-"$HOME/.local/share/wallpapers"}
WALLPAPER_PROG=${WALLPAPER_PROG:-wbg}
WALLPAPER_ARGS=${WALLPAPER_ARGS:-}

DATA_DIR='/tmp/wallpaper'
LOCK="$DATA_DIR/lock"
PID="$DATA_DIR/pid"

if [ ! -d "$WALLPAPER_DIR" ] || ! command -v "$WALLPAPER_PROG" >/dev/null 2>&1; then
	notify-send "$WALLPAPER_PROG not found!"
  exit 1
fi

[ -d "$DATA_DIR" ] || mkdir -p "$DATA_DIR"
{
	exec 4>"$LOCK"
	flock -n 4 || exit 1
}

exec >"$DATA_DIR/log" 2>&1

set_bg() {
	log 'info' "set wallpaper $1"
	$WALLPAPER_PROG $WALLPAPER_ARGS $1
}

interrupt_sleep() {
	if [ -n "${sleep_pid:-}" ]; then
		kill "$sleep_pid" 2>/dev/null || :
		pkill $WALLPAPER_PROG || :
	fi
	:> "$PID"
	log 'info' 'stopping'
}

trap 'exit 0' INT TERM
trap 'interrupt_sleep' USR1 EXIT
printf "%s\n" "$$" >"$PID"

while :; do
	wallpaper=$(find "$WALLPAPER_DIR" -type f -print \( -iname "*.png" -o -iname "*.jpg" \) | shuf -n 1)
	set_bg $wallpaper &
	sleep "$WALLPAPER_INTERVAL" &
	sleep_pid="$!"
	wait "$sleep_pid" || {
		log 'info' "killed $sleep_pid"
	}
done
