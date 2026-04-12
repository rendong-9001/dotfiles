## 1. Void Linux Installation Guide

### 1.1 Prepare Installation Media
Write the ISO to your USB device:
```sh
dd if=<your_iso_path> of=<your_device_path> status=progress bs=4M oflag=sync
```
> **Note:** Alternatively, you can create a bootable USB drive using tools like Ventoy or Rufus.

### 1.2 Set Console Font
If you are on a high-resolution display, increase the console font size for better readability:
```sh
bash && setfont sun12x22 # Or use your preferred font, alternatively: bash && setfont -d
```

### 1.3 Connect to Wi-Fi (Optional)
If you are using a wired connection, you can skip this step.
```sh
# Identify your network interface
ip -br link show

# Scan for available networks
wpa_cli -i <device> scan
wpa_cli -i <device> scan_results

# Generate the configuration and restart the service
wpa_passphrase "<SSID>" "<password>" > /etc/wpa_supplicant/wpa_supplicant.conf
sv restart wpa_supplicant

# Verify the connection
ip -br a show <device>
ping -c 5 8.8.8.8
```

### 1.4 Select a Repository Mirror
Select a mirror geographically closer to you for faster download speeds:
```sh
xmirror
```

### 1.5 Format NVMe SSD (Optional)
Reset the NVMe drive to factory state and set the optimal logical block size (LBA format).
```sh
xbps-install -S nvme-cli
nvme id-ns -H /dev/nvme0n1 | grep -i "^lba format"
nvme format /dev/nvme0n1 -f -s 1 -l 1
```

### 1.6 Partition the Drive
Create the necessary partitions using `fdisk`:
```sh
fdisk /dev/nvme0n1
```
> **Expected Layout Target:**
> `nvme0n1p1` - 1GB (EFI System Partition)
> `nvme0n1p2` - Remaining space (Linux LUKS partition)

### 1.7 Format Partitions (LUKS & LVM)
Create the FAT32 file system for the EFI partition:
```sh
mkfs.vfat -F32 -n "ESP" /dev/nvme0n1p1
```
Set up LUKS encryption on the second partition:
```sh
cryptsetup luksFormat /dev/nvme0n1p2
# Example with stronger encryption parameters (optional):
# cryptsetup luksFormat --type luks2 --key-size 512 --hash sha512 --iter-time 4000 \
# --sector-size 4096 --pbkdf-memory 2097152 --pbkdf-parallel 6 /dev/nvme0n1p2

cryptsetup open /dev/nvme0n1p2 cryptlvm
```
Configure Logical Volume Manager (LVM) inside the encrypted container:
```sh
pvcreate /dev/mapper/cryptlvm
vgcreate voidvg /dev/mapper/cryptlvm

# Create logical volumes (Adjust sizes according to your needs)
lvcreate -L 100G -n root voidvg
lvcreate -L 4G -n swap voidvg
lvcreate -l 100%FREE -n home voidvg

# Format the logical volumes
mkfs.xfs -L "ROOT" /dev/voidvg/root
mkfs.xfs -L "HOME" /dev/voidvg/home
mkswap -L "SWAP" /dev/voidvg/swap
```

### 1.8 Mount Filesystems
Mount the newly created filesystems to prepare for system installation:
```sh
mount /dev/voidvg/root /mnt
mount --mkdir /dev/nvme0n1p1 /mnt/efi
mount --mkdir /dev/voidvg/home /mnt/home
```

### 1.9 Install the Base System
Copy the repository keys to the target environment:
```sh
mkdir -p /mnt/var/db/xbps/keys/
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/
```
```sh
ARCH=$(uname -m)
REPO=$(xbps-query -L | awk 'NR==1 { print $2 }')

XBPS_ARCH=$ARCH xbps-install -S -r /mnt -R "$REPO" \
base-system lvm2 cryptsetup xmirror vim systemd-boot \
efibootmgr NetworkManager void-repo-nonfree cronie git zramen dracut-uefi zstd
```

### 1.10 Generate fstab
Generate the filesystem table using UUIDs:
```sh
xgenfstab -U /mnt > /mnt/etc/fstab
```

### 1.11 Chroot into the New System
Change root into your new Void Linux installation:
```sh
xchroot /mnt /bin/bash
```

### 1.12 Configure Locale
Uncomment your desired locale(s) in `/etc/default/libc-locales`:
```sh
echo 'en_US.UTF-8 UTF-8' >> /etc/default/libc-locales
xbps-reconfigure -f glibc-locales
```

### 1.13 Configure Hosts File
Set up your local hostname resolution:
```sh
cat <<EOF >> /etc/hosts
127.0.1.1   void-linux.localdomain void-linux
EOF
```

### 1.14 Configure DNS
Set up the DNS resolver:
```sh
echo 'nameserver 8.8.8.8' > /etc/resolv.conf.head
resolvconf -u
```

### 1.15 Configure System Settings (rc.conf)
Edit `/etc/rc.conf` to set essential system variables:
```sh
vim /etc/rc.conf
```
*Example configuration:*
```conf
HOSTNAME="void-linux"
HARDWARECLOCK="UTC"
TIMEZONE="Asia/Shanghai"
KEYMAP="us"
FONT="sun12x22"
```

### 1.16 Install and Configure Bootloader
Install `systemd-boot` to the EFI partition:
```sh
bootctl --esp-path=/efi install
```
Edit the bootloader configuration at `/efi/loader/loader.conf`:
```conf
timeout 10
console-mode max
default linux-*.efi
```

### 1.17 Configure Dracut (UKI)
Find your UUIDs first:
```sh
# Note the UUID of /dev/nvme0n1p2 (LUKS partition)
blkid -s UUID -o /dev/nvme0n1p2

# Note the UUID of /dev/mapper/voidvg-root (Root partition)
blkid -s UUID -o /dev/mapper/voidvg-root
```
Create the Dracut configuration file for the Unified Kernel Image (UKI) at `/etc/dracut.conf.d/55-uki.conf`:
```sh
vim /etc/dracut.conf.d/55-uki.conf
```
*Content (replace `<LUKS_UUID>` and `<ROOT_UUID>` with the output from `blkid`):*
```conf
kernel_cmdline="rd.lvm.vg=voidvg rd.luks.allow-discards rd.luks.uuid=<LUKS_UUID> root=UUID=<ROOT_UUID> rw"
add_dracutmodules+=" crypt lvm "
compress="zstd"
hostonly="yes"
```
Set `dracut-uefi` as the default initramfs generator:
```sh
xbps-alternatives -g initramfs -s dracut-uefi
```

### 1.18 Create User and Configure Sudo
Set the root password and create your standard user account:
```sh
passwd root

useradd -m -G wheel <username>
passwd <username>
```
Grant `sudo` privileges to users in the `wheel` group:
```sh
visudo
# Uncomment the line: %wheel ALL=(ALL:ALL) ALL
```

### 1.19 Enable System Services (runit)
Void Linux uses `runit`. You can symlink services to start them automatically on boot:
```sh
ln -s /etc/sv/NetworkManager /etc/runit/runsvdir/default/
ln -s /etc/sv/crond /etc/runit/runsvdir/default/
ln -s /etc/sv/zramen /etc/runit/runsvdir/default/
```

### 1.20 Reconfigure the System
This is a critical step. It configures installed packages, builds the initramfs, and generates the UKI EFI executables using dracut.
```sh
xbps-reconfigure -fa
```

### 1.21 Finish Installation
Exit the chroot environment, safely unmount the filesystems, and reboot:
```sh
exit
umount -R /mnt
reboot
```
