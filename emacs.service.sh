#!/bin/env bash

set -euox pipefail

#
# This ensures that the server is only started if there is a
# graphical session.
#

mkdir -p ~/.config/systemd/user/graphical-session.target.wants
ln -s /usr/lib/systemd/user/emacs.service \
~/.config/systemd/user/graphical-session.target.wants/emacs.service

#
# This makes the changes available in the current session.
#

systemctl --user daemon-reload
systemctl --user restart emacs.service
