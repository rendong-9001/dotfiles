#!/bin/sh
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=river

export XDG_DOWNLOAD_DIR="$HOME/downloads"
export XDG_DOCUMENTS_DIR="$HOME/documents"
export XDG_MUSIC_DIR="$HOME/music"
export XDG_PICTURES_DIR="$HOME/pictures"
export XDG_VIDEOS_DIR="$HOME/videos"

export XDG_CONFIG_HOME="$HOME/.config"      
export XDG_CACHE_HOME="$HOME/.cache"        
export XDG_DATA_HOME="$HOME/.local/share"  
export XDG_STATE_HOME="$HOME/.local/state"

exec  dbus-run-session river
