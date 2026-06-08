## Opendoas
### 1.1 Configure
edit /etc/doas.conf
```
permit persist setenv { PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin } :wheel
permit nopass keepenv :wheel as root cmd zzz
permit nopass :wheel as root cmd reboot
permit nopass :wheel as root cmd poweroff
```
```sh
chown -c root:root /etc/doas.conf
chmod -c 0400 /etc/doas.conf
```
