#!/bin/sh
set -eu

vars="
 PATH
 DISPLAY
 WAYLAND_DISPLAY
 XDG_DATA_HOME
 XDG_STATE_HOME
 XDG_CACHE_HOME
 XDG_CONFIG_HOME
 XDG_SESSION_TYPE
 XDG_CURRENT_DESKTOP
"

if command -v turnstile-update-runit-env >/dev/null 2>&1; then
	turnstile-update-runit-env $vars
fi

if command -v dbus-update-activation-environment >/dev/null 2>&1; then
	dbus-update-activation-environment $vars
fi
