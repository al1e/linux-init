#!/usr/bin/bash
# Maintained in linux-config.org
logger -t "startup-initfile"  BASH_PROFILE

[ -f ~/.profile ] && . ~/.profile || true
[ -f ~/.bashrc ] && . ~/.bashrc || true

## this bit sucks. start mbsync,time manually if enrypted homedir else it doesnt work
systemctl is-active --user mbsync.timer || systemctl --user start mbsync.timer

[ -f "${HOME}/.bash_profile.local" ] && . "${HOME}/.bash_profile.local"
[ -f "${HOME}/.START_SWAY" ] && [ $(tty) = /dev/tty1 ] && exec sway --my-next-gpu-wont-be-nvidia
