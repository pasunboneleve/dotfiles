Dotfiles
========

Here you find configuration files, usually symlinked somewhere else.

dconf
-----

To save: `dconf dump / > dconf-settings.ini`
To set:  `dconf load / < dconf-settings.ini`

nvidia
------

Check [rpmfusion - NVIDIA howto](https://rpmfusion.org/Howto/NVIDIA).

Also consider using vdpau instead of vaapi.

```
sudo dnf install nvidia-vdpau-driver --allowerasing
```
Finally, add `~/.config/environment.d/90-nvidia.conf`

```
__NV_PRIME_RENDER_OFFLOAD=1
__GLX_VENDOR_LIBRARY_NAME=nvidia
__VK_LAYER_NV_optimus=NVIDIA_only
```
to let `chrome` and friends to know they should use the NVIDIA GPU.
