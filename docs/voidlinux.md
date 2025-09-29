## 1.Void Linux Installation Guide
### 1.1 Prepare the Installation Media
```sh
dd if=<your_iso_path> of=<your_device_path> status=progress bs=4M oflag=sync
```
- Alternatively, you may use tools like Ventoy or Rufus to create a bootable USB drive.
### 1.2 Console font
```sh
bash # switch to bash shell
setfont sun12x22
```
### 1.3 Change mirror
```sh
xmirror # choose a preferred mirror
```
### 1.4 Connect to Wi-Fi
```sh
ip -brief link show
ip link set <device> up # run this if the interface is down
# Using iwd (recommended)
xbps-install -y iwd
rm /var/service/wpa_supplicant  # disable `wpa_supplicant`
ln -s /etc/sv/iwd /var/service/ # start `iwd` 

iwctl station <device> scan
iwctl station <device> get-networks 
iwctl --passphrase <your_password> station <device> connect <ssid>
# Using wpa_supplicant (default)
wpa_cli -i <device> scan
wpa_cli -i <device> scan_results
wpa_passphrase "ssid" "your_password" > /etc/wpa_supplicant/wpa_supplicant.conf
wpa_supplicant -B -i <device> -c /etc/wpa_supplicant/wpa_supplicant.conf
# verify connection
ip -brief addr show <device>
ping -c 5 www.github.com
```
### 1.5 Partitioning
```sh
fdisk /dev/nvme0n1 # alternatives: `parted`,`cfdisk`,`gdisk`

# Example layout:
# esp   /dev/nvme0n1p1
# root + swap (LVM on LUKS) /dev/nvme0n1p2
# home (LUKS) /dev/nvme0n1p3
```
### 1.6 Formatting (LVM on LUKS)
```sh
mkfs.vfat -F32 -n "ESP" /dev/nvme0n1p1

cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup luksFormat /dev/nvme0n1p3
# Example with stronger parameters:
# cryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 4000 \
# --pbkdf argon2id --pbkdf-memory 4194304 --pbkdf-parallel 6 --sector-size 4096

cryptsetup open /dev/nvme0n1p2 cryptlvm
cryptsetup open /dev/nvme0n1p3 crypthome

pvcreate /dev/mapper/cryptlvm # use `pvdisplay` to check
vgcreate vg1 /dev/mapper/cryptlvm # use `vgdisplay` to check 
lvcreate -L 32G -n swap vg1 # swap 
lvcreate -l 100%FREE -n root vg1 # root

mkfs.ext4 -L "HOME" /dev/nvme0n1p3
mkfs.ext4 -L "ROOT" /dev/vg1/root 
mkswap -L "SWAP" /dev/vg1/swap 
```
### 1.7 Mount Filesystems
```sh
mount /dev/vg1/root /mnt
mount --mkdir /dev/nvme0n1p1 /mnt/boot/ # or mount --mkdir /dev/nvme0n1p1 /mnt/efi/
mount --mkdir /dev/mapper/crypthome /mnt/home/
swapon /dev/vg1/swap 
```
- esp mount points [check](https://wiki.archlinux.org/title/EFI_system_partition#Typical_mount_points)
### 1.8 Install the Operating System
```sh
mkdir -p /mnt/var/db/xbps/keys/
cp /var/db/xbps/keys/* !$

ARCH=x86_64 # or x86_64-musl
REPO=https://mirrors.tuna.tsinghua.edu.cn/voidlinux/current
# replace with your preferred mirror, use `xbps-query -L` to get your current repo. 

# Standard installation
XBPS_ARCH=$ARCH xbps-install -S -r /mnt -R "$REPO" base-system lvm2 cryptsetup xmirror vim systemd-boot git mesa-dri elogind # add other packages you need.
# Minimal installation example
XBPS_ARCH=$ARCH xbps-install -S -r /mnt -R "$REPO" base-minimal lvm2 cryptsetup xmirror vim procps-ng limine \
bash tmux nftables xtools-minimal iproute2 bind-utils mdocml iwd dbus zramen acpid greetd tuigreet e2fsprogs \
ethtool cronie eudev man-pages seatd turnstile podman openssh kmod kbd opendoas void-artwork less xfsprogs swww \
dhcpcd usbutils pciutils flathub bubblewrap river fontconfig fcitx5 fcitx5-chinese-addons fcitx5-rime metalog \
dracut udisks2 mako libnotify wl-clipboard flatpak zathura zathura-pdf-mupdf rsyslog btop nvtop ncdu rsync sbctl \
imv mpv mpd mpc ncmpcpp grim slurp task tashwarrior-tui aria2 alsa-utils alsa-ucm-conf mtr bluetui bluez fuzzel \
tlp waydroid libvirt nmap ifupdown dmidecode hwinfo lshw void-repo-nonfree blender smartmontools tree dosfstools \
bash-completion helix zip unzip xz efibootmgr firefox noto-fonts-ttf noto-fonts-cjk noto-fonts-emoji \
nerd-fonts-symbols-ttf foot gammastep ironbar sandbar ffmpeg ImageMagick fcitx5-configtool virt-manager yt-dlp \
qemu-system-amd64 git gitui atac nnn yazi git-cliff just pkgconf
```
### 1.9 Generate fstab
```sh
xgenfstab -U /mnt > /mnt/etc/fstab # provideed by xtools package
```
### 1.10 Chroot into the system
```sh
xchroot /mnt /bin/bash
```
### 1.11 Configure locale (glibc only)
```sh
echo "LANG=en_US.UTF_8" > /etc/locale.conf
vim /etc/default/glibc-locales # uncommnt "en_US.UTF-8 UTF-8"
xbps-reconfigure -f glibc-locales
```
### 1.12 Set Hostname
```sh
echo "void-linux" > /etc/hostname
```
### 1.13 Configure Hosts File 
```sh
echo "127.0.1.1     void-linux.localdomain      void-linux" >> /etc/hosts
```
### 1.14 Configure DNS
```sh
echo "nameserver 1.1.1.1" > /etc/resolv.conf
```
### 1.15 Set System Clock 
```sh
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc
```
### 1.16 Configure rc.conf
- edit `/etc/rc.conf`
```
FONT=sun12x22
CGROUP_MODE=unified
```
### 1.17 Add a Keyfile for Home Encryption
```sh
dd if=/dev/urandom of=/root/crypt.key bs=1M count=1 # or head -c 1M /dev/urandom > /boot/crypt.key
cryptsetup luksAddKey /dev/nvme0n1p3 /root/crypt.key
chmod 400 /root/crypt.key
```
- edit `/etc/crypttab`
```
crypthome   UUID=<ROOT_UUID>   /root/crypt.key     luks,discard    
```
### 1.18 Install the Bootloader
```sh
bootctl --esp-path=/boot
bootctl install 
```
- edit `/boot/loader/entries/void-linux.conf`
```
title        Void Linux
options      rd.lvm.vg=vg1 rd.luks.allow-discards rd.luks.uuid=<LUKS_UUID> root=UUID=<ROOT_UUID> resume=UUID=<SWAP_UUID> rw
linux        vmlinuz-<version>
initrd       initramfs-<version>.img
```
- edit `/boot/loader/loader.conf`
```
timeout 10
default void-linux
console-mode max
```
### 1.19 Configure Dracut
- edit `/etc/dracut.conf.d/10-crypt.conf`
```
add_dracutmodules+=" crypt lvm resume "
compress="gzip"
hostonly="yes"
```
### 1.20 Create User 
```sh
passwd # set root password

useradd -m <username>
usermod -aG video,audio,input,wheel,_seatd <username>

visudo # uncomment %wheel ALL=(ALL:ALL) ALL
```
### 1.21 Reconfigure the System
```sh
xbps-reconfigure -fa
```
### 1.22 Finish Installation
```sh
exit # exit chroot
swapoff /dev/vg1/swap
umount -R /mnt
reboot  
```
### Secure boot (Optional)
Using uki + sbctl
- edit `/etc/dracut.conf.d/20-uki.conf` 
```
uefi_stub="/usr/lib/systemd/boot/efi/linuxx64.efi.stub"
kernel_cmdline="rootfstype=ext4 rd.lvm.vg=vg1 rd.luks.allow-discards rd.luks.uuid=5dca6223-39fc-4959-9b87-9f00b2aa16d6 rd.luks.name=5dca6223-39fc-4959-9b87-9f00b2aa16d6=cryptlvm root=UUID=0526d93f-8b27-458a-b177-2f46a1d1c490  rw"
uefi="yes"
```
```sh
# Generate the unified kernel image:
sudo dracut --force  --kver 6.12.34_1  --kernel-image /boot/vmlinuz-6.12.34_1  /boot/EFI/Linux/void-linux.efi
```
```sh
# Enroll keys and sign:
sudo xbps-install -y sbctl
sudo sbctl status # check setup mode is enabled
sudo sbctl enroll-keys --microsoft
sudo sbctl sign --save /boot/EFI/Linux/void-linux.efi
sudo efibootmgr --create --disk /dev/nvme0n1 --part 1  --label "Void Linux" --loader "EFI\Linux\void-linux.efi" # remember change bootorder
reboot
```

