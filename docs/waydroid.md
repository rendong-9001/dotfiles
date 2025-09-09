### Waydorid
## Install ashmem & binder (optional)
```sh
git clone https://github.com/choff/anbox-modules.git
```
## Fix Bug
```sh
sudo ln -sf /dev/binderfs/anbox-binder  /dev/binder
sudo ln -sf /dev/binderfs/anbox-vndbinder /dev/vndbinder
sudo ln -sf /dev/binderfs/anbox-hwbinder  /dev/hwbinder
sudo chmod  666 /dev/binder /dev/hwbinder /dev/vndbinder
# check if `ls /run/user/$(id -u)/pulse/native` exists
```
## Helper
```sh
git clone https://github.com/casualsnek/waydroid_script.git # install libndk or libhoudini
```
## Common Setting
```sh
waydroid show-full-ui
waydroid prop set persist.waydroid.multi_windows true
waydroid prop set persist.waydroid.width 1920
waydroid prop set persist.waydroid.height 1080
```
