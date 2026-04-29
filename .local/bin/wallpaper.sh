#!/bin/sh
set -eu

UID=$(id -u)
DATA_DIR="/tmp/wallpaper-$UID"
LOCK_FILE="$DATA_DIR/lock"
PID_FILE="$DATA_DIR/pid"

[ -d "$DATA_DIR" ] || mkdir -p "$DATA_DIR"

exec >"$DATA_DIR/log" 2>&1

cd "$(dirname $0)"

[ -f "./utils.sh" ] && . "./utils.sh" || { printf "%s" 'utils.sh not found!' ; exit 1; }

random_sleep 1 3

[ -f "$HOME/.config/wallpaper/config" ] && . "$HOME/.config/wallpaper/config"

: ${WALLPAPER_INTERVAL:=3600}
: ${WALLPAPER_DIR:="$HOME/.local/share/wallpapers"}
: ${WALLPAPER_PROG:=wbg}
: ${WALLPAPER_ARGS:=}

CURRENT_BG_PID=''
CURRENT_SLEEP_PID=''

if [ ! -d "$WALLPAPER_DIR" ] || ! command -v "$WALLPAPER_PROG" >/dev/null 2>&1; then
    notify-send "Wallpaper script error" "$WALLPAPER_PROG or directory not found!"
    exit 1
fi

{
	exec 4>"$LOCK_FILE"
	flock -n 4 || exit 1
}

set_bg() {
	log 'info' "Setting wallpaper: $1"
	$WALLPAPER_PROG $WALLPAPER_ARGS "$1" &
    _bg_pid=$!
    sleep 0.5
    if [ -n "$CURRENT_BG_PID" ] && kill -0 "$CURRENT_BG_PID" 2>/dev/null; then
        kill "$CURRENT_BG_PID" 2>/dev/null || :
        log 'info' "Killed old process (PID: $CURRENT_BG_PID)"
    fi
    CURRENT_BG_PID=$_bg_pid
}

interrupt_sleep() {
    log 'info' 'Received signal, skipping to next wallpaper'
    if [ -n "$CURRENT_SLEEP_PID" ]; then
        kill "$CURRENT_SLEEP_PID" 2>/dev/null || :
    fi
}

cleanup() {
    log 'info' 'Daemon stopping, cleaning up'
    :> "$PID_FILE"
    if [ -n "$CURRENT_BG_PID" ]; then
        kill "$CURRENT_BG_PID" 2>/dev/null || :
    fi
    interrupt_sleep
    exit 0
}

trap 'exit 0' TERM INT
trap 'cleanup' EXIT
trap 'interrupt_sleep' USR1
printf "%s\n" "$$" >"$PID_FILE"

while :; do
	wallpaper=$(find "$WALLPAPER_DIR" -type f -print \( -iname "*.png" -o -iname "*.jpg" \) | shuf -n 1)
	set_bg $wallpaper
	sleep "$WALLPAPER_INTERVAL" &
	CURRENT_SLEEP_PID=$!
	wait "$CURRENT_SLEEP_PID" || {
		log 'info' "Killed current_sleep_pid: $CURRENT_SLEEP_PID" 
	}
done
