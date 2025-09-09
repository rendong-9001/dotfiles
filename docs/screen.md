## Screen
## 1.wlr-randr
### 1.1 Set Mode
```sh
wlr-randr --output HDMI-A-1 --custom-mode 1920x1080@60Hz
wlr-randr --output HDMI-A-1 --mode 1920x1080@60Hz
```
### 1.2 Set Position
```sh
# HDMI-A-1 eDP-1
wlr-randr --output HDMI-A-1 --mode 1920x1080@60Hz --pos 0,0 --output eDP-1 --mode 1920x1080@60Hz --pos 1080,0
```
## 2.Brightnessctl
### 2.1
```sh
brightnessctl set 50%+ / -10%
```
## 3.wl-mirror
### 3.1 mirror
```sh
wl-mirror HDMI-A-1
```
