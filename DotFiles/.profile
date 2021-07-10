# Maintained in linux-config.org
logger -t "startup-initfile"  PROFILE

# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022


export PRINTER="Canon_TR8500_series"

export PROMPT_COMMAND='history -a'

export ALTERNATE_EDITOR=""
export EDITOR="emacsclient -t"
export VISUAL="emacsclient -c"

export HISTSIZE=2056
export HISTCONTROL=ignoreboth:erasedups

# export PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/share/pkgconfig

export ARDUINO_SDK_PATH="${HOME}"/Dropbox/homefiles/development/arduino/arduinoSDK
export CMAKE_EXPORT_COMPILE_COMMANDS=1

export RIPGREP_CONFIG_PATH="${HOME}"/.ripgreprc

#alias man=eman

export PATH="${HOME}/bin":"${HOME}/bin/sway":"${HOME}/.local/bin":"${HOME}/.emacs.d/bin":"./node_modules/.bin":"${PATH}"

export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
export USE_GPG_FOR_SSH="yes" # used in xsession

if [ -z "$XDG_CONFIG_HOME" ]
then
    export XDG_CONFIG_HOME="$HOME/.config"
fi

# for sway waybar tray
export XDG_CURRENT_DESKTOP=Unity


[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

export FZF_TMUX_OPTS=1
export FZF_TMUX_OPTS="-d 40%"

export XKB_DEFAULT_LAYOUT=de
export XKB_DEFAULT_OPTIONS=ctrl:nocaps

export PATH="${HOME}"/bin/llvm:"${HOME}"/bin/llvm/build/bin:"$PATH"

export PURE_PYTHON=1

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

export USER_STARTX_START=

[ -f "$HOME/.profile.local" ] && . "$HOME/.profile.local"
