#!/bin/sh
set -eu

sleep 1 
WALLPAPER_INTERVAL=${WALLPAPER_INTERVAL:-3600}
WALLPAPER_DIR=${WALLPAPER_DIR:-"$HOME/.local/share/wallpapers"}
WALLPAPER_PROG="swww"

trap 'logger -t "wallpaper.sh" -p "user.info" "terminating"; exit 0' INT TERM

if [ ! -d "$WALLPAPER_DIR" ] || ! command -v "$WALLPAPER_PROG" >/dev/null 2>&1; then 
  	exit 1
fi

while :; do
	if ! pgrep -x 'swww-daemon' >/dev/null 2>&1; then
		logger -t 'wallpaper.sh' -p 'user.err' 'swww-daemon: not running'
		sleep 2
		continue
	fi
	wallpaper=$(find "$WALLPAPER_DIR" -type f -print \( -iname "*.png" -o -iname "*.jpg" \) | shuf -n 1)
	swww img -t outer --transition-pos top $wallpaper
	sleep "$WALLPAPER_INTERVAL"
done
