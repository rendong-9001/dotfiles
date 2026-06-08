#!/bin/sh
set -eu

for _cmd in grim slurp; do
    command -v "$_cmd" >/dev/null 2>&1 || {
        notify-send -u normal "${0##*/}" "Error: $_cmd is not installed." || :
        exit 1
    }
done

: "${XDG_CONFIG_HOME:=$HOME/.config}"
if [ -f "$XDG_CONFIG_HOME/user-dirs.dirs" ]; then
    # shellcheck source=/dev/null
    . "$XDG_CONFIG_HOME/user-dirs.dirs"
fi
: "${XDG_PICTURES_DIR:=$HOME/Pictures}"

timestamp() { date +%F-%H~%M-%S; }

check_esc() {
    if [ -z "$1" ]; then
        notify-send -u normal "${0##*/}" "Capture cancelled." || :
        exit 0
    fi
}

MODE="${1:-region}"
SCREENSHOTS_PATH="$XDG_PICTURES_DIR/screenshots"
[ -d "$SCREENSHOTS_PATH" ] || mkdir -p "$SCREENSHOTS_PATH"
FILE="$SCREENSHOTS_PATH/$(timestamp).png"

case "$MODE" in
    full)
        grim - | tee "$FILE" | wl-copy
        ;;
    window)
        exit 0
        # TODO
        ;;
    region)
        _region="$(slurp || true)"
        check_esc "$_region"
        grim -g "$_region" - | tee "$FILE" | wl-copy
        ;;
    *)
        exit 0
        ;;
esac

notify-send -u normal "${0##*/}" "Screenshot has been placed in the clipboard"
