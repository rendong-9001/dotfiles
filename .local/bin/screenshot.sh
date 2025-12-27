#!/bin/sh

for cmd in grim slurp; do
	command -v "$cmd" >/dev/null 2>&1 || { notify-send "$cmd not installed"; exit 1; }
done

MODE="${1:-region}"

SCREENSHOTS_PATH="$XDG_PICTURES_DIR/Screenshots"
[ -d "$SCREENSHOTS_PATH" ] || mkdir -p "$SCREENSHOTS_PATH"

check_esc() {
	if [ -z "$1"]; then
		notify-send "Screenshot" "Capture cancelled"
		exit 0
	fi
}

FILE="$SCREENSHOTS_PATH/$(date +%F-%H-%M-%S).png"

case "$MODE" in
	full)
		grim - | tee "$FILE" | wl-copy  
		;;
	window)
		exit 0 
		# todo
		;;
	region)
		_region="$(slurp)"
		check_esc "$_region"
		grim -g "$_region" - | tee "$FILE" | wl-copy 
		;;
	*)
		exit 0
		;;
esac

notify-send "Copied" "Screenshot has been placed in the clipboard"
