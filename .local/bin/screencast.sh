#!/bin/sh
set -eu

for _cmd in fuzzel wf-recorder wlr-randr; do
    if ! command -v "$_cmd" >/dev/null 2>&1; then
        notify-send -u normal "${0##*/}" "Error: $_cmd is not installed." || :
        exit 1
    fi
done

: "${XDG_CONFIG_HOME:=$HOME/.config}"
if [ -f "$XDG_CONFIG_HOME/user-dirs.dirs" ]; then
    # shellcheck source=/dev/null
    . "$XDG_CONFIG_HOME/user-dirs.dirs"
fi
: "${XDG_VIDEOS_DIR:=$HOME/Videos}"

timestamp() { date +%F-%H~%M-%S; }

SCREENCASTS_PATH="$XDG_VIDEOS_DIR/screencasts"
[ -d "$SCREENCASTS_PATH" ] || mkdir -p "$SCREENCASTS_PATH"

case "$1" in
    start)
        _file="$SCREENCASTS_PATH/$(timestamp).mkv"
        _output=$(wlr-randr | awk '!/^[[:space:]]/ { print $1 }' | fuzzel -d -p "Select Output:")
        _fps=$(printf '%s\n' 45 60 120 | fuzzel -d -p "Select FPS:")
        wf-recorder -r "${_fps:-60}" -f "$_file" -o "$_output" >/dev/null 2>&1 &
        notify-send -u normal "${0##*/}" "Recording started" || :
        ;;
    stop)
        pkill wf-recorder >/dev/null 2>&1 || :
        notify-send -u normal "${0##*/}" "Recording finished" || :
        ;;
    *)
        exit 0
        ;;
esac
