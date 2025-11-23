#!/bin/sh

sleep 1 
WALLPAPER_DIR="$HOME/.local/share/wallpapers"
WALLPAPER_PROG="$(which swww)"

while :; do
	if ! command -v "$WALLPAPER_PROG" >/dev/null 2>&1; then
			sleep 1
			continue
	fi
	wallpaper=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
	swww img -t outer --transition-pos top $wallpaper
	sleep 3600
done
