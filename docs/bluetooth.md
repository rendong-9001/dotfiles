## Bluetooth
### 1.1 Prerequisites
```sh
sudo xbps-install -S ntfs-3g chntpw
```
- `Important: Disable "Fast Startup" in Windows Settings (Power Options), otherwise the NTFS partition will be locked as "dirty" and unmountable in Linux`
### 1.2 Extract the Windows Link Key
```sh
# 1. Mount Windows C: drive (replace nvme0n1p3 with your actual partition)
sudo mount -t ntfs-3g -o ro /dev/nvme0n1p3 /mnt/

# 2. Open the Windows System Registry
sudo chntpw -e /mnt/Windows/System32/config/system

# 3. Inside the chntpw interactive shell, run:
# cd ControlSet001\Services\BTHPORT\Parameters\Keys
# ls
# cd <adapter_mac_address>
# ls
# hex <device_mac_address>
# q (to quit)
```
- `Take note of the 16-byte hex string (e.g., BE 7F ... 16 8A)`
### 1.3 Sync the Key to Linux
```sh
# 1. Format the key: Remove all spaces and ensure it is a continuous string (e.g., BE7FB199...)
# 2. Edit the config
sudo vim /var/lib/bluetooth/<adapter_mac>/<device_mac>/info
# 3. Update the [LinkKey] section
# [LinkKey]
# Key=YOUR_EXTRACTED_KEY_HERE
# 4. Restart the Bluetooth service
sudo sv restart bluetoothd
```
