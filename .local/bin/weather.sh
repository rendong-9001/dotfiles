#!/bin/sh

sleep 3
FILE_PATH='/tmp/weather'
CITY=${CITY:-'武汉'}
WEATHER_INTERVAL=${WEATHER_INTERVAL:-1800}

trap 'logger -t "weather.sh" -p "user.info" "terminating"; exit 0' INT TERM

[ -f "$FILE_PATH" ] || :>"$FILE_PATH"

while :; do
	if ! command -v curl >/dev/null 2>&1; then
		logger -t 'weather.sh' -p 'user.err' 'curl: not found'
		sleep 2
		continue
	fi
	weather=$(curl -s --max-time 3 wttr.in/$CITY?format=%l:+%C+%t\&lang=zh 2>/dev/null)
	if [ -n "$weather" ]; then
		echo "$weather" > "$FILE_PATH"
	fi
	sleep $WEATHER_INTERVAL
done
