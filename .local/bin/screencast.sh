#!/bin/sh

for cmd in fuzzel wf-recorder; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        notify-send "$cmd not installed"
        exit 1
    fi
done

SCREENCAP_PATH="$XDG_VIDEOS_DIR/Screencasts"
[ -d "$SCREENCAST_PATH" ] || mkdir -p "$SCREENCAP_PATH"
FILE="$SCREENCAST_PATH/$(date +%F-%H-%M-%S).mp4"

case "$1" in
    start)
        _output=$(wlr-randr | awk -F '[" ]' '/^[^ ]/ {print $1}' | fuzzel -d -p "Select Output:")
        _fps=$(echo "45\n60\n120" | fuzzel -d -p "Select FPS:")
        echo $_fps > /tmp/test
        wf-recorder -r "${_fps:-60}" --audio -f "$FILE" -o "$_output" >/dev/null 2>&1 &
        notify-send "Screencast" "Recording started"
        ;;
    stop)
        pkill wf-recorder >/dev/null 2>&1
        notify-send "Screencast" "Recording finished"
        ;;
    *)
        exit 0
        ;;
esac
