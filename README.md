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

Then add [mutter-primary-gpu.rules](62-mutter-primary-gpu.rules) to
`/etc/udev/rules.d` and reboot. Make sure you read the instructions.
Unless you make **gnome-shell** work with **NVIDIA**, you'll need to
tell every application individually to do so, which would be a hassle.
