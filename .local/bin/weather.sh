#!/bin/sh

sleep 5
FILE_PATH='/tmp/weather'
CITY='武汉'
INTERVAL=1800

[ -f "$FILE_PATH" ] || :>"$FILE_PATH"
while :; do
	weather=$(curl -s --max-time 3 wttr.in/$CITY?format=%l:+%C+%t\&lang=zh 2>/dev/null)
	if [ -n "$weather" ]; then
		echo "$weather" > "$FILE_PATH"
	fi
	sleep $INTERVAL
done
