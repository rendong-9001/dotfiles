## IW
### Regdomain
```sh
sudo xbps-install -S wireless-regdb iw

# Sometimes the country code is incorrect,resulting in restricted Wi-Fi bands.
sudo iw reg get
# Fix
sudo ip link set <device> down
sudo iw reg set 00
sudo iw reg set CN
sudo ip link set <device> up
# Verify
sudo iw reg get
sudo iw list | less
# Persist the country code setting
echo 'iw reg set CN' | sudo tee -a /etc/rc.local
```
