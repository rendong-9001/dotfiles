#!/bin/sh
set -eu

UID=$(id -u)
PID_FILE="/tmp/wallpaper-$UID/pid"
kill -USR1 $(cat < $PID_FILE) || :
