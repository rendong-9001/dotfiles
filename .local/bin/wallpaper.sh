#!/bin/sh
set -eu

sleep 1 
WALLPAPER_INTERVAL=${WALLPAPER_INTERVAL:-3600}
WALLPAPER_DIR=${WALLPAPER_DIR:-"$HOME/.local/share/wallpapers"}
WALLPAPER_PROG="swww"

if [ ! -d "$WALLPAPER_DIR" ] || ! command -v "$WALLPAPER_PROG" >/dev/null 2>&1; then 
  exit 1
fi

interrupt_sleep() {
	if [ -n "${_sleep_pid:-}" ]; then
		kill "$_sleep_pid" 2>/dev/null || :
	fi
}

trap 'interrupt_sleep' USR1
trap '{ interrupt_sleep; exit 0; }' INT TERM EXIT

while :; do
	if ! pgrep -x 'swww-daemon' >/dev/null 2>&1; then
		logger -t 'wallpaper.sh' -p 'user.err' 'swww-daemon: not running'
		sleep 1
		continue
	fi
	wallpaper=$(find "$WALLPAPER_DIR" -type f -print \( -iname "*.png" -o -iname "*.jpg" \) | shuf -n 1)
	swww img -t outer --transition-pos top $wallpaper
	sleep "$WALLPAPER_INTERVAL" &
	_sleep_pid="$!"
	wait "$_sleep_pid" || :
done
