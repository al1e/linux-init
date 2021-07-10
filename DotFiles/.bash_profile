#!/usr/bin/env bash
# Maintained in linux-config.org
logger -t "startup-initfile"  BASH_PROFILE

[ -f ~/.profile ] && . ~/.profile || true
[ -f ~/.bashrc ] && . ~/.bashrc || true
## this bit sucks. start mbsync,time manually if enrypted homedir else it doesnt work
systemctl is-active --user mbsync.timer || systemctl --user start mbsync.timer

dropbox-start-once &> /dev/null  &

if command -v guix; then
    echo "GUIX initialised."
    GUIX_PROFILE="/home/rgr/.guix-profile"
    . "$GUIX_PROFILE/etc/profile"
fi

[ -f "${HOME}/.bash_profile.local" ] && . "${HOME}/.bash_profile.local"

if [ -f "${HOME}/.START_SWAY" ]; then
    if [ $(tty) = /dev/tty1 ];then
        if  [ $(hostname) = "xmgneo" ];then
            exec sway --my-next-gpu-wont-be-nvidia
        else
            exec sway
        fi
    fi
fi
