#!/usr/bin/bash
# Maintained in linux-init-files.org
logger -t "startup-initfile"  BASH_PROFILE

[ -f ~/.profile ] && . ~/.profile || true
[ -f ~/.bashrc ] && . ~/.bashrc || true

## this bit sucks. start mbsync,time manually if enrypted homedir else it doesnt work
systemctl is-active --user mbsync.timer || systemctl --user start mbsync.timer
dropbox-start-once async

# # disable tracker
# gsettings set org.freedesktop.Tracker.Miner.Files crawling-interval -2
# gsettings set org.freedesktop.Tracker.Miner.Files enable-monitors false

[ -f "${HOME}/.bash_profile.local" ] && . "${HOME}/.bash_profile.local"
[ $(tty) = /dev/tty1 ] && exec sway
