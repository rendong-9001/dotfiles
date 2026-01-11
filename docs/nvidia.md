## Nvidia
### 1.nvidia-container-toolkit
```sh
sudo nvidia-ctk cdi generate --output /etc/cdi/nvidia.yaml
```
### 2.hibernate
```sh
echo 'omit_drivers+=" nvidia nvidia_drm nvidia_modeset nvidia_uvm "' | sudo tee -a /etc/dracut.conf.d/20-uki.conf
sudo xbps-reconfigure -f linux6.12-$(uname -r)
```
