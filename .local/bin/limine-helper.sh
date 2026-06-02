#!/bin/sh
set -eu

: "${LIMINE_CONFIG:=/efi/limine/limine.conf}"
: "${LIMINE_EFI_DEST:=/efi/EFI/BOOT/BOOTX64.EFI}"
: "${LIMINE_EFI_ORIGIN:=/usr/share/limine/BOOTX64.EFI}"

usage() {
	cat << EOF
Usage: ${0##*/} [OPTIONS]

Limine bootloader management utility.

Options:
  -h              Show this help message and exit
  -x <path>       Set custom EFI binary path (default: $LIMINE_EFI_PATH)
  -c <path>       Set custom config path (default: $LIMINE_CONFIG_PATH)
  -e              Enroll config hash into the EFI binary
  -r              Reset enrolled config hash from the EFI binary
  -u              Update EFI binary

Examples:
  ${0##*/} -e                          Enroll current config
  ${0##*/} -c /custom/limine.conf -e   Enroll custom config
EOF
}

info() {
	printf "%s\n" "$1"
}

die() {
	printf "%s\n" "error: $1"
	exit 1
}

validate() {
	if [ ! -f "$LIMINE_CONFIG" ]; then
		die "$LIMINE_CONFIG: such file or directory"
	fi
	if [ ! -f "$LIMINE_EFI_ORIGIN" ]; then
		die "$LIMINE_EFI_ORIGIN: such file or directory"
	fi
}

cleanup() {
	rm -f "${LIMINE_EFI_DEST}.tmp" || :
}

enroll() {
	config_b2sum=$(b2sum "$LIMINE_CONFIG" | cut -d ' ' -f 1)
	limine enroll-config "$LIMINE_EFI_DEST" "$config_b2sum"
}

reset() {
	limine enroll-config --reset "$LIMINE_EFI_DEST"
}

update() {
	cp "$LIMINE_EFI_ORIGIN" "${LIMINE_EFI_DEST}.tmp"
	mv "${LIMINE_EFI_DEST}.tmp" "$LIMINE_EFI_DEST"
}

DO_ENROLL=0
DO_RESET=0
DO_UPDATE=0

while getopts "hx:c:eru" opt; do
    case "$opt" in
        h) usage
			exit 0
			;;
        x) LIMINE_EFI_PATH="$OPTARG"
			;;
        c) LIMINE_CONFIG_PATH="$OPTARG"
			;;
		e) DO_ENROLL=1
			;;
		r) DO_RESET=1
			;;
		u) DO_UPDATE=1
			;;
        *) exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

validate

trap 'cleanup' EXIT

[ "$DO_RESET" = "1" ] && reset
[ "$DO_UPDATE" = "1" ] && update
[ "$DO_ENROLL" = "1" ] && enroll

info "Done!"
