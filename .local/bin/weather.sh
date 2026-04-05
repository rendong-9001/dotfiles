#!/bin/sh
set -eu

cd "$(dirname $0)"

. "./utils.sh"

random_sleep 1 3

. "$HOME/.config/weather/config"

CITY=${CITY:-武汉}
WEATHER_INTERVAL=${WEATHER_INTERVAL:-30m}

DATA_DIR="/tmp/weather"
LOCK="$DATA_DIR/lock"
PID="$DATA_DIR/pid"
RESULT="$DATA_DIR/result"

[ -d "$DATA_DIR" ] || mkdir -p "$DATA_DIR"
{
	exec 4>"$LOCK"
	flock -n 4 || exit 1
}

exec >"$DATA_DIR/log" 2>&1

if ! command -v curl >/dev/null 2>&1; then
	log 'error' 'curl not found'
	exit 1
fi

cleanup() {
	if [ -n "${sleep_pid:-}" ]; then
		kill "$sleep_pid" 2>/dev/null || :
	fi
	:> "$PID"
	log 'info' 'stopping'
}

trap 'exit 0' TERM INT
trap 'cleanup' EXIT
printf "%s\n" "$$" >"$PID"

retry=0
while [ "$retry" -lt 10 ]; do
	URL="wttr.in/$CITY?format=%l:+%C+%t&lang=zh"
	weather=$(curl -s --max-time 3 "$URL") || {
		log "error" "failed to obtain weather"
	}
	if [ -z "$weather" ]; then
		sleep 5
		retry=$((retry + 1))
		continue
	fi
	tmp_result="$(mktemp "$DATA_DIR/result.XXXXXX")" || exit 1
	printf "%s\n" "$weather" > "$tmp_result" && mv "$tmp_result" "$RESULT"
	sleep "$WEATHER_INTERVAL" &
	sleep_pid="$!"
	wait "$sleep_pid" || {
		log 'info' "killed $sleep_pid"
	}
done
