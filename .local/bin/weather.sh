#!/bin/sh
set -eu

CITY=武汉
WEATHER_INTERVAL=30m
DATA_DIR="/tmp/weather"
LOCK="$DATA_DIR/lock"
PID="$DATA_DIR/pid"
RESULT="$DATA_DIR/result"

[ -d "$DATA_DIR" ] || mkdir -p "$DATA_DIR"
{
	exec 3>"$LOCK"
	flock -n 3 || exit 1
}
exec >"$DATA_DIR/log" 2>&1
timestamp() { date +%F-%H-%M-%S; }
log() {
	printf "%s [%s]: %s\n" "$(timestamp)" "$1" "$2"
}
if ! command -v curl >/dev/null 2>&1; then
	log 'error' 'curl not found'
	exit 1
fi
cleanup() {
	log 'info' 'stopping'
	if [ -n "${sleep_pid:-}" ]; then
		kill "$sleep_pid" 2>/dev/null || :
	fi
	:> "$PID"
}
trap '{ cleanup; exit 0; }' TERM INT EXIT
printf "%s\n" "$$" >"$PID"

while :; do
	URL="wttr.in/$CITY?format=%l:+%C+%t&lang=zh"
	weather=$(curl -s --max-time 3 "$URL") || {
		log "error" "failed to obtain weather"
	}
	if [ -z "$weather" ]; then
		sleep 5
		continue
	fi
	tmp_result="$(mktemp "$DATA_DIR/result.XXXXXX")" || exit 1
	printf "%s\n" "$weather" >"$tmp_result" && mv "$tmp_result" "$RESULT"
	sleep "${WEATHER_INTERVAL:-1800}" &
	sleep_pid="$!"
	wait "$sleep_pid" || {
		log 'info' "killed $sleep_pid"
	}
done
