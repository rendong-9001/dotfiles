#!/bin/sh
set -eu

: "${XDG_RUNTIME_DIR:=/tmp}"

UID=$(id -u)
DATA_DIR='wallpaper'
PID_FILE="$XDG_RUNTIME_DIR/$DATA_DIR-$UID/pid"

kill -USR1 $(cat < $PID_FILE) || :
