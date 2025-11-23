## Monitor
### 1. Set Mode
```sh
wlr-randr --output HDMI-A-1 --custom-mode 1920x1080@60Hz
wlr-randr --output HDMI-A-1 --mode 1920x1080@60Hz
```
### 2. Set Position
```sh
# HDMI-A-1 eDP-1
wlr-randr --output HDMI-A-1 --mode 1920x1080@60Hz --pos 0,0 --output eDP-1 --mode 1920x1080@60Hz --pos 1080,0
```
### 3. Brightness
```sh
brightnessctl set 50%+
brightnessctl set -20%
ddcutil -d 1 setvcp 10 70
ddcutil -d 1 setvcp 10 + 20
```
## 4. Mirror
```sh
wl-mirror HDMI-A-1
```
