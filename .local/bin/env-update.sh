#!/bin/sh
set -eu

UPDATE_ENV_PROG='dbus-update-activation-environment'

if command -v turnstile-update-runit-env >/dev/null 2>&1 ; then
    UPDATE_ENV_PROG='turnstile-update-runit-env'
fi

"$UPDATE_ENV_PROG" \
    DISPLAY \
    WAYLAND_DISPLAY \
    XDG_RUNTIME_DIR \
    XDG_CURRENT_DESKTOP
