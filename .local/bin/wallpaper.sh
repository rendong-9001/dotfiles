#!/bin/sh
set -eu
 
WALLPAPER_INTERVAL=${WALLPAPER_INTERVAL:-3600}
WALLPAPER_DIR=${WALLPAPER_DIR:-"$HOME/.local/share/wallpapers"}
WALLPAPER_PROG="swww"
DATA_DIR='/tmp/wallpaper'
LOCK="$DATA_DIR/lock"
PID="$DATA_DIR/pid"

[ -d "$DATA_DIR" ] || mkdir -p "$DATA_DIR"
{
	exec 4>"$LOCK"
	flock -n 4 || exit 1
}
exec >"$DATA_DIR/log" 2>&1
timestamp() { date +%F-%H-%M-%S; }
log() {
	printf "%s [%s]: %s\n" "$(timestamp)" "$1" "$2"
}

if [ ! -d "$WALLPAPER_DIR" ] || ! command -v "$WALLPAPER_PROG" >/dev/null 2>&1; then
  exit 1
fi

interrupt_sleep() {
	if [ -n "${_sleep_pid:-}" ]; then
		kill "$_sleep_pid" 2>/dev/null || :
	fi
	:> "$PID"
}

trap 'exit 0' INT TERM
trap 'interrupt_sleep' USR1 EXIT
printf "%s\n" "$$" >"$PID"

while :; do
	if ! pgrep -x 'swww-daemon' >/dev/null 2>&1; then
		log 'error' 'swww-daemon: not running'
		sleep 1
		continue
	fi
	wallpaper=$(find "$WALLPAPER_DIR" -type f -print \( -iname "*.png" -o -iname "*.jpg" \) | shuf -n 1)
	swww img -t outer --transition-pos top $wallpaper
	sleep "$WALLPAPER_INTERVAL" &
	_sleep_pid="$!"
	wait "$_sleep_pid" || {
		log 'info' "killed $_sleep_pid"
	}
done
