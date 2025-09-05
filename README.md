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
