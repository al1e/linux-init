#!/usr/bin/bash
# Maintained in linux-init-files.org
logger -t "startup-initfile"  BASH_PROFILE

[ -f ~/.profile ] && . ~/.profile || true
[ -f ~/.bashrc ] && . ~/.bashrc || true

## this bit sucks. start mbsync,time manually if enrypted homedir else it doesnt work
systemctl is-active --user mbsync.timer || systemctl --user start mbsync.timer
dropbox-start-once async

# disable tracker
gsettings set org.freedesktop.Tracker.Miner.Files crawling-interval -2
gsettings set org.freedesktop.Tracker.Miner.Files enable-monitors false

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

[ -f "${HOME}/.bash_profile.local" ] && . "${HOME}/.bash_profile.local"
# export USER_STARTX_NO_LOGOUT_ON_QUIT=""
[ -z "$DISPLAY" ] && [ $(tty) = /dev/tty1 ] && [ -f ~/.START_X ] && {
    echo "Auto starting via startx with USER_STARTX_NO_LOGOUT_ON_QUIT:${USER_STARTX_NO_LOGOUT_ON_QUIT}"
    [ -z "$USER_STARTX_NO_LOGOUT_ON_QUIT" ] && exec startx || startx
}
