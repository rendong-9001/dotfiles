#!/bin/sh
set -eu

UID=$(id -u)
DATA_DIR="/tmp/weather-$UID"
LOCK_FILE="$DATA_DIR/lock"
PID_FILE="$DATA_DIR/pid"
RESULT="$DATA_DIR/result"

[ -d "$DATA_DIR" ] || mkdir -p "$DATA_DIR"

exec >"$DATA_DIR/log" 2>&1

cd "$(dirname $0)"

[ -f "./utils.sh" ] && . "./utils.sh" || { printf "%s" 'utils.sh not found!' ; exit 1; }

random_sleep 1 3

[ -f "$HOME/.config/weather/config" ] && . "$HOME/.config/weather/config"

: ${CITY:=Beijing}
: ${WEATHER_INTERVAL:=30m}

CURRENT_SLEEP_PID=''

{
	exec 4>"$LOCK_FILE"
	flock -n 4 || exit 1
}

if ! command -v curl >/dev/null 2>&1; then
	log 'error' 'curl not found'
	exit 1
fi

cleanup() {
	log 'info' 'Daemon stopping, cleaning up'
	:> "$PID_FILE"
	if [ -n "$CURRENT_SLEEP_PID" ]; then
		kill "$CURRENT_SLEEP_PID" 2>/dev/null || :
	fi
}

trap 'exit 0' TERM INT
trap 'cleanup' EXIT
printf "%s\n" "$$" >"$PID_FILE"

retry=0
while [ "$retry" -lt 10 ]; do
	URL="wttr.in/$CITY?format=%l:+%C+%t&lang=zh-cn"
	weather=$(curl -s --max-time 2 "$URL") || {
		log "error" "Failed to obtain weather"
	}
	if [ -z "$weather" ]; then
		sleep 5
		retry=$((retry + 1))
		continue
	fi
	tmp_result="$(mktemp "$DATA_DIR/result.XXXXXX")" || exit 1
	printf "%s\n" "$weather" > "$tmp_result" && mv "$tmp_result" "$RESULT"
	sleep "$WEATHER_INTERVAL" &
	CURRENT_SLEEP_PID=$!
	wait "$CURRENT_SLEEP_PID" || {
		log 'info' "Killed current_sleep_pid: $CURRENT_SLEEP_PID"
	}
done
