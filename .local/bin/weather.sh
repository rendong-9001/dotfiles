#!/bin/sh
set -eu

: "${XDG_RUNTIME_DIR:=/tmp}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"

: ${CITY:=Beijing}
: ${WEATHER_INTERVAL:=30m}

UID=$(id -u)
DATA_DIR="weather"
CURRENT_SLEEP_PID=''

RUNTIME_DIR="$XDG_RUNTIME_DIR/$DATA_DIR-$UID"

PID_FILE="$RUNTIME_DIR/pid"
LOCK_FILE="$RUNTIME_DIR/lock"
LOG_FILE="$XDG_STATE_HOME/$DATA_DIR/log"
RESULT="$XDG_CACHE_HOME/$DATA_DIR/result"

mkdir -p \
	"$RUNTIME_DIR" \
	"$XDG_CACHE_HOME/$DATA_DIR" \
	"$XDG_STATE_HOME/$DATA_DIR"

exec >"$LOG_FILE" 2>&1

cd "$(dirname $0)"

[ -f "./utils.sh" ] && . "./utils.sh" || {
	printf "%s" 'utils.sh not found!'
	exit 1
}

random_sleep 1 3

[ -f "$XDG_CONFIG_HOME/weather/config" ] && . "$XDG_CONFIG_HOME/weather/config"

{
	exec 4>"$LOCK_FILE"
	flock -n 4 || exit 1
}

if ! command -v curl >/dev/null 2>&1; then
	log 'error' 'curl not found'
	exit 1
fi

interrupt_sleep() {
	log 'info' 'Received signal, skipping to next weather'
	if [ -n "$CURRENT_SLEEP_PID" ]; then
		kill "$CURRENT_SLEEP_PID" 2>/dev/null || :
	fi
}

cleanup() {
	log 'info' 'Daemon stopping, cleaning up'
	:> "$PID_FILE"
	if [ -n "$CURRENT_SLEEP_PID" ]; then
		kill "$CURRENT_SLEEP_PID" 2>/dev/null || :
	fi
}

trap 'cleanup' EXIT
trap 'exit 0' TERM INT
trap 'interrupt_sleep' USR1

printf "%s\n" "$$" >"$PID_FILE"

retry=0
while [ "$retry" -lt 10 ]; do
	URL="wttr.in/$CITY?format=4"
	weather=$(curl -s --max-time 3 "$URL") || {
		log "error" "Failed to obtain weather"
	}
	if [ -z "$weather" ]; then
		sleep 5
		retry=$((retry + 1))
		continue
	fi
	tmp_result="${RESULT}.tmp"
	printf "%s\n" "$weather" > "$tmp_result" && mv "$tmp_result" "$RESULT"
	sleep "$WEATHER_INTERVAL" &
	CURRENT_SLEEP_PID=$!
	wait "$CURRENT_SLEEP_PID" || {
		log 'info' "Killed current_sleep_pid: $CURRENT_SLEEP_PID"
	}
done

notify-send 'weather.sh' 'Faild to obtain weather' || :
