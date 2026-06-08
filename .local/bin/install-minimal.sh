#!/bin/sh
# shellcheck disable=SC2086
set -eu

: "${ARCH:=$(xbps-uhelper arch)}"
: "${REPO:=$(xbps-query -L | awk 'NR==1{ print $2 }')}"
: "${TARGET_PATH:=/mnt}"

PKGS='
 base-minimal
 xmirror
 ncurses
 libgcc
 less
 file
 bash
 man-pages
 mdocml
 dosfstools
 e2fsprogs
 xfsprogs
 usbutils
 pcitils
 openssh
 kbd
 iputils
 iproute2
 iw
 iwd
 dhcpcd
 void-artwork
 mtr
 ethtool
 kmod
 acpid
 eudev
 dracut-uefi
 sof-firmware
 linux-firmware
'

kernel() {
    case "$1" in
        lts)
            PKGS="${PKGS} linux"
            ;;
        mainline)
            PKGS="${PKGS} linux-mainline"
            ;;
        *)
            PKGS="${PKGS} linux"
            ;;
    esac
}

sudo_or_doas() {
    case "$1" in
        sudo)
            PKGS="${PKGS} sudo"
            ;;
        doas)
            PKGS="${PKGS} opendoas doasedit"
            ;;
        *)
            PKGS="${PKGS} sudo"
            ;;
    esac
}

nonfree_repo() {
    case "$1" in
        enable)
            PKGS="${PKGS} void-repo-nonfree"
            ;;
        *)
            ;;
    esac
}

install_system() {
    mkdir -p "$TARGET_PATH/var/db/xbps/keys/"
    cp /var/db/xbps/keys/* "$TARGET_PATH/var/db/xbps/keys/"

    XBPS_ARCH="$ARCH" xbps-install \
        -S \
        -r "$TARGET_PATH" \
        -R "$REPO" \
        $PKGS

    xgenfstab -U "$TARGET_PATH" >"$TARGET_PATH/etc/fstab"
    echo 'void-linux' >"$TARGET_PATH/etc/hostname"
    xchroot "$TARGET_PATH"
}

run() {
    kernel lts
    sudo_or_doas sudo
    nonfree_repo enable
    install_system
}

run
