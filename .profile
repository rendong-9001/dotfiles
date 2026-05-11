# vim: ft=sh noet ts=4 sw=4
# PATH
case ":${PATH}:" in
	*:"$HOME/.local/bin":*)
		;;
	*) export PATH="$HOME/.local/bin:$PATH"
		;;
esac
# XDG
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
# nvidia
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
# apps
if [ "$XDG_SESSION_TYPE" = wayland ]; then
	# fcitx5
	export XMODIFIERS=@im=fcitx
	# EFL-based
	export ELM_DISPLAY=wl
	# SDL-based
	export SDL_VIDEODRIVER=wayland
	# GTK
	export GTK_THEME=Adwaita:dark
	# Qt
	export QT_QPA_PLATFORM=wayland
	export QT_QPA_PLATFORMTHEME=qt6ct
fi
