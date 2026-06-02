#!/bin/sh
set -eu

: "${ARCH:=x86_64}"
: "${REPO:=$(xbps-query -L | awk 'FNR==1{ print $2 }')}"
: "${INSATLL_PATH:=/mnt}"

packages="
 base-minimal
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
 sudo
 wifi-firmware
 void-artwork
 mtr
 ethtool
 kmod
 acpid
 eudev
 dracut-uefi
 sof-firmware
 linux6.18
 linux-firmware-amd
"

XBPS_ARCH=$ARCH xbps-install \
	-S \
	-r $INSTALL_PATH \
	-R $REPO \
	$packages
