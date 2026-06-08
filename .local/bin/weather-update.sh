#!/bin/sh
set -eu

: "${XDG_RUNTIME_DIR:=/tmp}"

UID=$(id -u)
DATA_DIR="weather"
PID_FILE="$XDG_RUNTIME_DIR/$DATA_DIR-$UID/pid"
PID=$(cat "$PID_FILE")

if [ -z "$PID" ]; then
    notify-send "${0##*/}" "Daemon may not running" || :
    exit 1
fi

kill -USR1 "$PID" 2>/dev/null || :
