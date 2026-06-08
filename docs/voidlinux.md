## 1. Void Linux Installation Guide

### 1.1 Prepare Installation Media
Write the ISO to your USB device:
```sh
dd if=<iso_file> of=<usb_device> bs=4M status=progress oflag=sync
```
> **Note:** Alternatively, you can create a bootable USB drive using tools like Ventoy or Rufus.

### 1.2 Set Console Font (Optional)
If you are using a high-resolution display, increase the console font size for better readability:
```sh
setfont -d
```

### 1.3 Connect to Wi-Fi (Optional)
If you are using a wired connection, you can skip this step:
```sh
# Identify your network interface
ip -br link show

# Scan for available networks
wpa_cli -i <interface> scan
wpa_cli -i <interface> scan_results

# Generate Wi-Fi configuration and restart the service
wpa_passphrase <SSID> <PASSWORD> >> /etc/wpa_supplicant/wpa_supplicant.conf
sv restart wpa_supplicant

# Verify the connection
ip -br a show <interface>
ping -c 5 8.8.8.8
```

### 1.4 Select a Repository Mirror
Select a mirror geographically closer to you for faster download speeds:
```sh
xmirror
```

### 1.5 Format the NVMe SSD (Optional)
Securely erase the NVMe drive and set the LBA format to native 4K sector size.
```sh
# Install NVMe management tools
xbps-install -S nvme-cli

# List available LBA formats (look for "LBA Format" entries)
nvme id-ns -H /dev/nvme0n1 | grep -i '^lba format'

# Securely erase and format with native 4K (replace <lbaf_index> with the index from above)
nvme format --force -s 1 -l <lbaf_index> /dev/nvme0n1
```

### 1.6 Partition the Drive
Create the necessary partitions using `fdisk`:
```sh
fdisk /dev/nvme0n1
```
> **Target partition layout:**
> `nvme0n1p1` - 1GB (EFI System Partition)
> `nvme0n1p2` - Remaining space (Linux LUKS partition)

### 1.7 Format Partitions (LUKS & LVM)
Format the EFI partition as FAT32:
```sh
mkfs.vfat -F32 -n 'ESP' /dev/nvme0n1p1
```
Initialize LUKS encryption on the second partition:
```sh
cryptsetup luksFormat /dev/nvme0n1p2
# Example with stronger encryption parameters (Optional):
# cryptsetup luksFormat --type luks2 --key-size 512 --iter-time 4000 \
# --sector-size 4096 --pbkdf-memory 2097152 /dev/nvme0n1p2

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
mkfs.xfs -L 'ROOT' /dev/voidvg/root
mkfs.xfs -L 'HOME' /dev/voidvg/home
mkswap -L 'SWAP' /dev/voidvg/swap
```

### 1.8 Mount Filesystems
Mount the newly created filesystems to prepare for system installation:
```sh
mkdir /mnt/void
mount /dev/voidvg/root /mnt/void
mount --mkdir /dev/nvme0n1p1 /mnt/void/efi
mount --mkdir /dev/voidvg/home /mnt/void/home
```

### 1.9 Install the Base System
Copy the repository signing keys into the target system:
```sh
mkdir -p /mnt/void/var/db/xbps/keys/
cp /var/db/xbps/keys/* /mnt/void/var/db/xbps/keys/
```
```sh
ARCH=$(uname -m)
REPO=$(xbps-query -L | awk 'NR==1 { print $2 }')

XBPS_ARCH=$ARCH xbps-install -S -r /mnt/void -R "$REPO" \
base-system lvm2 cryptsetup xmirror vim systemd-boot zstd dracut-uefi \
efibootmgr NetworkManager void-repo-nonfree cronie zramen chrony
```

### 1.10 Generate fstab
Generate the filesystem table using UUIDs:
```sh
xgenfstab -U /mnt/void > /mnt/void/etc/fstab
```

### 1.11 Chroot into the New System
Change root into your new Void Linux installation:
```sh
xchroot /mnt/void
```

### 1.12 Configure Locale
Add your desired locale(s) to /etc/default/libc-locales:
```sh
echo 'en_US.UTF-8 UTF-8' >> /etc/default/libc-locales
xbps-reconfigure -f glibc-locales
```

### 1.13 Configure Hosts and Hostname Files
Define the system hostname:
```sh
echo 'void-linux' > /etc/hostname
```
Set up your local hostname resolution:
```sh
cat <<EOF >> /etc/hosts
127.0.1.1    void-linux.localdomain    void-linux
EOF
```

### 1.14 Configure DNS
Set up the DNS resolver:
```sh
echo 'nameserver 8.8.8.8' > /etc/resolv.conf.head
resolvconf -u
```

### 1.15 Configure System Settings (rc.conf)
Set localization, hardware clock, and console preferences in `/etc/rc.conf`:
```sh
cat <<EOF >> /etc/rc.conf
HARDWARECLOCK="UTC"
TIMEZONE="Asia/Shanghai"
KEYMAP="us"
FONT="sun12x22"
EOF
```

### 1.16 Install and Configure Bootloader
Install the bootloader:
```sh
bootctl --esp-path=/efi install
```
Configure the loader options:
```sh
cat <<EOF > /efi/loader/loader.conf
timeout 10
console-mode max
default linux-*.efi
EOF
```

### 1.17 Configure Dracut (UKI)
First, retrieve the UUIDs of the relevant partitions:
```sh
# LUKS partition UUID
LUKS_UUID=$(blkid -s UUID -o value /dev/nvme0n1p2)

# Root partition UUID (inside LVM)
ROOT_UUID=$(blkid -s UUID -o value /dev/mapper/voidvg-root)
```
Create the Dracut configuration file for the Unified Kernel Image (UKI):
```sh
cat <<EOF > /etc/dracut.conf.d/55-uki.conf
kernel_cmdline="psi=1 rd.lvm.vg=voidvg rd.luks.allow-discards rd.luks.uuid=${LUKS_UUID} root=UUID=${ROOT_UUID} rw"
add_dracutmodules+=" crypt lvm "
compress="zstd"
hostonly="yes"
EOF
```
Set `dracut-uefi` as the default initramfs generator:
```sh
xbps-alternatives -g initramfs -s dracut-uefi
```
Override the default UKI output directory:
```sh
echo 'UEFI_BUNDLE_DIR="efi/EFI/Linux"' >> /etc/default/dracut-uefi-hook
```

### 1.18 Create User and Configure Sudo
Set the root password and create your standard user account:
```sh
passwd root

useradd -m -G wheel <USERNAME>
passwd <USERNAME>
```
Grant `sudo` privileges to users in the `wheel` group:
```sh
echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/wheel
```

### 1.19 Enable System Services (runit)
Enable essential services to start automatically on boot by symlinking them:
```sh
ln -s /etc/sv/NetworkManager /etc/runit/runsvdir/default/
ln -s /etc/sv/crond /etc/runit/runsvdir/default/
ln -s /etc/sv/zramen /etc/runit/runsvdir/default/
```

### 1.20 Reconfigure the System
Reconfigure all installed packages. This will automatically rebuild the initramfs and generate the UKI via Dracut:
```sh
xbps-reconfigure -fa
```

### 1.21 Finish Installation
Exit the chroot environment, unmount all filesystems, and reboot your system:
```sh
exit
umount -R /mnt/void
reboot
```
