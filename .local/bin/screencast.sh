#!/bin/sh
set -eu

for cmd in fuzzel wf-recorder wlr-randr; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        notify-send "$cmd not installed"
        exit 1
    fi
done

timestamp() { date +%F-%H-%M-%S; }

SCREENCASTS_PATH="$XDG_VIDEOS_DIR/Screencasts"
[ -d "$SCREENCASTS_PATH" ] || mkdir -p "$SCREENCAPS_PATH"
FILE="$SCREENCASTS_PATH/$(timestamp).mp4"

case "$1" in
    start)
        _output=$(wlr-randr | awk '!/^[[:space:]]/ { print $1 }' | fuzzel -d -p "Select Output:")
        _fps=$(printf '%s\n' 45 60 120 | fuzzel -d -p "Select FPS:")
        wf-recorder -r "${_fps:-60}" --audio -f "$FILE" -o "$_output" >/dev/null 2>&1 &
        notify-send "Screencast" "Recording started"
        ;;
    stop)
        pkill wf-recorder >/dev/null 2>&1 || true
        notify-send "Screencast" "Recording finished"
        ;;
    *)
        exit 0
        ;;
esac
