#!/bin/sh

random_sleep() {
    min=$1
    max=$2
    delay=$(awk -v min="$min" -v max="$max" 'BEGIN{srand(); print min + (max - min) * rand()}')
    sleep "$delay"
}

timestamp() { date +%F-%H-%M-%S; }

log() {
	printf "%s [%s]: %s\n" "$(timestamp)" "$1" "$2"
}
