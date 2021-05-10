# Introduction


## Status

Work in progress!! Keep all config and scripts in a single org file for documentation. Use org tangling for exporting them.


## GIT


### ~/.gitconfig

global git settings NB - NOT Exported as lots of things want to update it

```conf
# Maintained in linux-init-files.org
[user]
name = rileyrg
email = rileyrg@gmx.de
[push]
default = current
[github]
user = rileyrg
```


### master branch, no commit

```bash
#!/bin/sh
branch="$(git rev-parse --abbrev-ref HEAD)"
if [ "$branch" = "master" ]; then
    echo "You can't commit directly to master branch"
    exit 1
fi
```


# X Related

Manual setup files for startx. See <http://bhepple.com/doku/doku.php?id=starting_x>


## ~/.xinitrc

I use this as a kind of placeholder to remind me that system xinitrc is doing the work.

```conf
#!/usr/bin/bash
# Maintained in linux-init-files.org
# Dont need that as startx will use xinitc anyway if this doesnt exist.
rm ~/.xsession-errors
. /etc/X11/xinit/xinitrc
```


## ~/.xprofile

Another placeholder doing nothing as xinit launches XSession which uses .xsession and .xsessionrc on Debian

```bash
# Maintained in linux-init-files.org
# all moved to .xsessionrc so /etc/X11/Xsession loads it

```


## ~/.xsession

[/etc/X11/Xsession.d](file:///etc/X11) does the most work. It's processed by [startx](file:///usr/bin/startx)->[xinitrc](file:///etc/X11/xinit/xinitrc) which in turn calls [/etc/X11/Xsession](file:///etc/X11/Xsession)

```bash
#!/usr/bin/env bash
# Maintained in linux-init-files.org

logger -t "startup-initfile"  USER-XSESSION
exec dbus-launch --sh-syntax --exit-with-session i3
```


## ~/.xsessionrc

```bash
#!/usr/bin/bash
# Maintained in linux-init-files.org
logger -t "startup-initfile"  XSESSIONRC
xhost +

xset s off
xset -dpms

xrdb -merge ~/.Xresources

# .xsessionrc.local for this type of thing
case "$(hostname)" in
    "thinkpadt460")
        # disable trackpad
        xinput set-prop $(xinput list --id-only "SynPS/2 Synaptics TouchPad") "Device Enabled" 0
        # picom --backend glx --vsync &
        ;;
    "thinkpadt14s")
        #picom --backend glx --vsync &
        ;;
    "thinkpadx270")
        #picom --backend glx --vsync &
        ;;
    "xmgneo")
        # xrandr --output eDP-1 --mode 2560x1440 --rate 165 #--scale 0.8x0.8
        #picom --backend glx --vsync &
        ;;
    *)
        # picom --backend glx --vsync &
        ;;
esac

[ -f "${HOME}"/.config/user-dirs.dir ] && . "${HOME}"/.config/user-dirs.dir || true

# command -v srandrd && srandrd xrandr-smart-connect
[ -z "$(pidof "pulseaudio")" ] &> /dev/null  && pulseaudio -D


# leave to local machine
# xss-lock -- i3lock -n -c 000000 &
x-idlehook &
(post-lock && post-blank) &
(sleep 2 && gpg-cache)&

[ -f "${HOME}"/.xsessionrc.local ] && . "${HOME}"/.xsessionrc.local || true

```


## ~/.xsessionrc.local

Add machine specifics. The xmg neo 15 [keyboard backlight repo](https://github.com/pobrn/ite8291r3-ctl) for example.

```bash
#!/usr/bin/bash
# Maintained in linux-init-files.org
logger -t "startup-initfile"  XSESSIONRC-LOCAL
# sugestions for .xsessionrc.local
# export XIDLEHOOK_KBD=60
# export XIDLEHOOK_DIM=120
# export XIDLEHOOK_BLANK=600
# export XIDLEHOOK_LOCK=7200
# export XIDLEHOOK_SUSPEND=3600
```


## ~/.Xresources

```conf
! Use a truetype font and size.
*.font: -*-JetBrainsMono Nerd Font-*-*-*-*-6-*-*-*-*-*-*
Xft.autohint: 0
Xft.antialias: 1
Xft.hinting: true
Xft.hintstyle: hintslight
Xft.dpi: 96
Xft.rgba: rgb
Xft.lcdfilter: lcddefault

! Fonts {{{
#ifdef SRVR_thinkpadt460
Xft.dpi:       104
#endif
#ifdef SRVR_intelnuc
Xft.dpi:       108
#endif
#ifdef SRVR_thinkpadx270
Xft.dpi:       96
#endif
#ifdef SRVR_thinkpadt14s
Xft.dpi:       96
#endif
#ifdef SRVR_xmgneo
Xft.dpi:       188
#endif
! }}}

```


## ~/bin/x-lock-utils

Just a gathering place of locky/suspendy type things&#x2026;

```bash
#!/usr/bin/bash
# Maintained in linux-init-files.org

# lock() {
#     logger -t "x-lock-utils"  lock
#     pre-lock
#     xbacklight -set 5
#     xset dpms 5 0 0
#     i3lock -n -c 000000
#     xset -dpms
#     x-backlight-persist restore
#     post-lock
# }
lock() {
    xset dpms force off && i3lock -n -c 000000
}

lock_gpg_clear() {
    logger -t "x-lock-utils"  lock_gpg_clear
    [ "$1" = gpg_clear ] &&  (echo RELOADAGENT | gpg-connect-agent &>/dev/null )
    lock
}

case "$1" in
    lock)
        lock
        ;;
    lock_gpg_clear)
        lock_gpg_clear
        ;;
    logout)
        i3-msg exit
        ;;
    suspend)
        systemctl suspend && i3lock -n -c 000000
        ;;
    hibernate)
        systemctl hibernate i3lock -n -c 000000
        ;;
    reboot)
        systemctl reboot
        ;;
    shutdown)
        systemctl poweroff
        ;;
    screenoff)
        xset dpms force off
        ;;
    *)
        lock
        ;;
esac

exit 0
```


## xidlehook for handling dim and pause prefs

See [xidlehook](https://github.com/jD91mZM2/xidlehook). Better handling of idle things. Dont dim or blank when watching a video or in full screen. [acpilight](https://gitlab.com/wavexx/acpilight ) provides a better xbacklight.\*


### ~/bin/x-idlehook

```bash
#!/usr/bin/bash
# Maintained in linux-init-files.org

xidlehook \
    `# Don't lock when there's a fullscreen application` \
    --not-when-fullscreen \
    `# Don't lock when there's audio playing` \
    --not-when-audio \
    --timer ${XIDLEHOOK_KBD:-60}\
    'pre-blank' \
    'post-blank' \
    --timer ${XIDLEHOOK_DIM:-180}\
    'command -v brightnessctl && brightnessctl s 10' \
    'post-blank' \
    --timer ${XIDLEHOOK_BLANK:-120}\
    'xset dpms force off' \
    'post-blank'
    # --timer ${XIDLEHOOK_LOCK:-2400}\
    # '(pre-lock && x-lock-utils lock)' \
    # '(post-blank && post-lock)' \
    # --timer ${XIDLEHOOK_SUSPEND:-3600}\
    # 'systemctl suspend' \
    # ''
```


## ~/bin/rnv

enable force of nvidia driver - run with nvidia

```bash
#!/usr/bin/bash
# Maintained in linux-init-files.org
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia ${@}
```


## ~/bin/x-backlight-persist

Save and restore backlight values

```bash
#!/usr/bin/bash
# Maintained in linux-init-files.org

save() {
    l=$(xbacklight -get);
    echo  $l > ~/.x-backlight-persist
    echo $l
}

get() {
    if command -v brightnessctl; then
        echo $(brightnessctl g)
    else
        echo $(xbacklight -get);
    fi
}

restore() {
    b=100
    [ -f ~/.x-backlight-persist ] && read b < ~/.x-backlight-persist
    xbacklight -set $b
    echo $b
}

case "$1" in
    save)
        command -v brightnessctl && brightnessctl -s && exit 0
        save
        [ -n "$2" ] && xbacklight -set "$2"
        ;;
    restore)
        command -v brightnessctl && brightnessctl -r && exit 0
        restore
        ;;
    get)
        get
        ;;
    *)
        save
        ;;
esac

exit 0

```


## xrandr monitor related

Differnt monitors have different resolutions and hence DPI


### utility functions

1.  xrandr-dpi-calc

    org code block to calculate the DPI - pass inWidth as width in inches, else cmWidth as&#x2026;. yay!

    ```emacs-lisp
    (let*((inWidth (or (if (eq inWidth 0)(/ cmWidth 2.54) inWidth )))
          (dpi (/ xRes inWidth)))
      (setq rgr/monitor-DPI dpi)
      (format "DPI of %.1f inch width screen with a horizontal pixel count of %d is: %d"
              inWidth xRes dpi))
    ```

2.  xrandr-connected-active

    ```bash
    #!/usr/bin/bash
    # Maintained in linux-init-files.org
    XRANDR_CONNECTED_ACTIVE="$(xrandr --listactivemonitors | tail -n +2  | awk '{print $4}')"
    echo "$XRANDR_CONNECTED_ACTIVE"
    ```

3.  ~/bin/xrandr-connected

    list connected ids

    ```bash
    #!/usr/bin/bash
    # Maintained in linux-init-files.org
    export XRANDR_CONNECTED=$(xrandr -q | grep -iw "connected" | awk '{print $1}')
    echo "$XRANDR_CONNECTED"
    ```

4.  ~/bin/xrandr-connected-first

    return the id of the first display reported by xrandr

    ```bash
    #!/usr/bin/bash
    # Maintained in linux-init-files.org
    xrandr-connected | head -n 1 | awk '{print $1}'
    ```

5.  ~/bin/xrandr-disconnected

    list disconnected

    ```bash
    #!/usr/bin/bash
    # Maintained in linux-init-files.org
    xrandr -q | grep -w "disconnected" | awk '{print $1}'
    ```

6.  ~/bin/xrandr-disconnected-off

    turn off all disconnected

    ```bash
    #!/usr/bin/bash
    # Maintained in linux-init-files.org
    xargs -I {} xrandr --output {} --off <<< $(xrandr-disconnected)
    ```

7.  ~/bin/xrandr-connected-external

    ```bash
    #!/usr/bin/bash
    # Maintained in linux-init-files.org
    export XRANDR_EXTERNAL="$(xrandr-connected | awk '{print $1}' | grep -i "^[hdmi|d]" | head -n 1)"
    echo "$XRANDR_EXTERNAL"
    ```

8.  ~/bin/xrandr-connected-primary

    set the primary display to arg1 else set first in list thats on

    ```bash
    #!/usr/bin/bash
    # Maintained in linux-init-files.org
    primary="${1-$(xrandr-connected-active|head -n 1)}"
    existingprimary="$(xrandr -q | grep -w "primary" | awk '{print $1}')"
    [ "${existingprimary}" != "${primary}" ] &&
        xrandr --output "${primary}" --primary
    echo "${primary}"
    ```

9.  ~/bin/xrandr-laptop-id

    ```bash
    xrandr-connected | grep -i "^[el]"
    ```

10. ~/bin/xrandr-laptop

    ```bash
    #!/usr/bin/bash
    # Maintained in linux-init-files.org
    on=${1:-"on"}
    l="$(xrandr-laptop-id)"
    if [ -z "$l" ]; then
        echo "No laptop screen detected."
    else
        if [ "$on" = "off" ]; then
            # echo "Turning off "${l}"."
            # xrandr --output "$l" --off
            e="$(xrandr-connected-external)"
            if [ -z "$e"]; then
                echo "No external monitor so not turning off laptop"
            else
                echo "Mirroring laptop ${l} to external ${e} since turning it off causés X to move at a snail's pace"
                xrandr --output "${e}" --same-as "${l}"
            fi
        else
            echo "Turning on "${l}"."
            xrandr-smart-connect
        fi
    fi
    ```

11. ~/bin/xrandr-multi

    ```bash
    #!/usr/bin/bash
    # Maintained in linux-init-files.org
    on=${1:-"on"}
    as_primary=${2:-"yes"}
    extmonitor=$(xrandr-connected-external | head -n 1)
    first=$(xrandr-connected-first)
    if [ ! -z "$extmonitor" ] && [ "$extmonitor" != "$first" ]; then
        echo "Detected 2nd monitor $extmonitor"
        if [ "$on" = "on" ]; then
            echo "Turning on $extmonitor"
            xrandr --output "$extmonitor" --auto  --right-of "$first" &> /dev/null;
            if [ "${as_primary}" = "yes" ]; then
                xrandr --output "${extmonitor}" --primary
            else
                xrandr-connected-primary
            fi
        else
            echo "Turning off  $extmonitor"
            xrandr --output "$extmonitor" --off  &> /dev/null;
            xrandr-connected-primary "$(xrandr-laptop-id)"  &> /dev/null
        fi
    else
        echo "no addtional external monitors detected so turning off all disconnected anyway..."
        xrandr-disconnected-off
    fi

    ```

12. ~/bin/xrandr-mancave

    ```bash
    #!/usr/bin/bash
    # Maintained in linux-init-files.org
    on=${1:-"on"}
    connected=${2:-$(xrandr-connected-external | head -n 1)}
    laptop=$(xrandr-laptop-id)
    if  [ -z "$connected" ] ;then
        echo "Not connected to external monitor so making laptop primary"
        xrandr-connected-primary
    else
        if [ "$on" = "on" ]; then
            xrandr --output "$laptop"  --off
            xrandr --output "$connected" --mode 2560x1440  --rate 74.6 --primary --dpi "108"
            xrandr --output "$laptop"  --right-of "$connected" --auto # --scale "${scale:-"1x1"}"
        else
            xrandr-multi off
        fi
    fi
    ```

13. ~/bin/xrandr-smart-connect

    connect to richie's monitors by default if we can

    ```bash
    #!/usr/bin/bash
    # Maintained in linux-init-files.org
    # turn off call disconnected displays
    xrandr-disconnected-off
    # try and ID the display connected and act accordingly
    connectedmodestring="$(xrandr -q | grep -A 1 -w "connected" | grep -A 1 -i "^[hd||d]" | tail -n 1 | awk '{print $1}')"
    if [ ! -z "$connectedmodestring" ]; then
        case "$connectedmodestring" in
            *2560*)
                xrandr-mancave on
                ;;
            *)
                xrandr-multi on
                ;;
        esac
    else
        xrandr-multi off
    fi
    ```

14. connect/disconnect daemon

    Note these are not used now in favour of the [srandr](https://github.com/jceb/srandrd) daemon

    1.  ~/bin/xrandr-smart-connect-daemon

        ```bash
        #!/usr/bin/bash
        # Maintained in linux-init-files.org
        while true; do
            sleep 5
            [ -z "$(pidof "steam")" ] && xrandr-smart-connect &> /dev/null
        done


        ```

    2.  ~/bin/xrandr-smart-connect-daemon-run

        ```bash
        #!/usr/bin/bash
        # Maintained in linux-init-files.org
        if pidof -x xrandr-smart-connect-daemon &> /dev/null; then
            echo "$0 already running."
            exit 1;
        fi
        xrandr-smart-connect-daemon &
        ```


### x270

    DPI of 11.0 inch width screen with a horizontal pixel count of 1920 is: 174

1.  ~/bin/xrandr-x270-bigtv

    ```bash
    #!/usr/bin/bash
    # Maintained in linux-init-files.org
    xrandr-multi "$@"
    ```

2.  ~/bin/xrandr-x270-mancave

        DPI of 23.6 inch width screen with a horizontal pixel count of 2560 is: 108

    ```bash
    #!/usr/bin/bash
    # Maintained in linux-init-files.org
    xrandr-mancave "$@"
    ```


### XMG Neo 15

1.  ~/bin/xrandr-xmgneo-bigtv

    ```bash
    #!/usr/bin/bash
    # Maintained in linux-init-files.org
    xrandr-multi on "$@"
    ```

2.  ~/bin/xrandr-xmgneo-mancave

        DPI of 23.6 inch width screen with a horizontal pixel count of 2560 is: 108

    ```bash
    #!/usr/bin/bash
    # Maintained in linux-init-files.org
    dpi=188 xrandr-mancave "$@"
    ```


# User system services


### gpg-agent

If using startx on debian this is taken care of by the system XSession loading everyhing in /etc/X11/Xsession.d. see [/usr/share/doc/gnupg/examples](file:///usr/share/doc/gnupg/examples)


# Bash Startup Files

<https://linuxize.com/post/bashrc-vs-bash-profile/> ,-&#x2014;

| Bash Startup Files                                                                                                                                                                                                                                                                                                |
| When invoked as an interactive login shell, Bash looks for the *etc/profile file, and if the file exists , it runs the commands listed in the file. Then Bash searches for ~*.bash\_profile, ~/.bash\_login, and ~/.profile files, in the listed order, and executes commands from the first readable file found. |
| When Bash is invoked as an interactive non-login shell, it reads and executes commands from ~/.bashrc, if that file exists, and it is readable.                                                                                                                                                                   |
| Difference Between .bashrc and .bash\_profile                                                                                                                                                                                                                                                                     |
| .bash\_profile is read and executed when Bash is invoked as an interactive login shell, while .bashrc is executed for an interactive non-login shell.                                                                                                                                                             |
| Use .bash\_profile to run commands that should run only once, such as customizing the $PATH environment variable .                                                                                                                                                                                                |
| Put the commands that should run every time you launch a new shell in the .bashrc file. This include your aliases and functions , custom prompts, history customizations , and so on.                                                                                                                             |
| Typically, ~/.bash\_profile contains lines like below that source the .bashrc file. This means each time you log in to the terminal, both files are read and executed.                                                                                                                                            |
| if [ -f ~/.bashrc ]; then                                                                                                                                                                                                                                                                                         |
| . ~/.bashrc                                                                                                                                                                                                                                                                                                       |
| fi                                                                                                                                                                                                                                                                                                                |
| Copy                                                                                                                                                                                                                                                                                                              |
| Most Linux distributions are using ~/.profile instead of ~/.bash\_profile. The ~/.profile file is read by all shells, while ~/.bash\_profile only by Bash.                                                                                                                                                        |
| If any startup file is not present on your system, you can create it.                                                                                                                                                                                                                                             |

\`-&#x2014;


<a id="orgbbb8554"></a>

## ~/.profile

```bash
# Maintained in linux-init-files.org
logger -t "startup-initfile"  PROFILE

# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022


export PRINTER="EPSON_XP-820_Series"

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

export PATH="${HOME}/bin":"${HOME}/.local/bin":"${HOME}/.emacs.d/bin":"${HOME}/.cargo/bin":"./node_modules/.bin":"${PATH}"

export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
export USE_GPG_FOR_SSH="yes" # used in xsession

if [ -z "$XDG_CONFIG_HOME" ]
then
    export XDG_CONFIG_HOME="$HOME/.config"
fi


```


<a id="orgeb7d002"></a>

## ~/.bash\_profile

```bash
#!/usr/bin/bash
# Maintained in linux-init-files.org
logger -t "startup-initfile"  BASH_PROFILE

[ -f ~/.profile ] && . ~/.profile || true
[ -f ~/.bashrc ] && . ~/.bashrc || true

## this bit sucks. start mbsync,time manually if enrypted homedir else it doesnt work
systemctl is-active --user mbsync.timer || systemctl --user start mbsync.timer
dropbox-start-once async
```


## ~/.bashrc

```bash
#!/usr/bin/bash
# Maintained in linux-init-files.org
logger -t "startup-initfile"  BASHRC
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    dumb) color_prompt=no;;
    xterm-256color) color_prompt=no;;
    *) color_prompt=no
       ;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=no
    fi
fi

if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

stty -ixon

GPG_TTY=$(tty)
export GPG_TTY

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

```


# ZSH Related


## ~/.config/zsh/.zshrc

```bash
# Maintained in linux-init-files.org
logger -t "startup-initfile"  ZSHRC
[[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return
export TERM="xterm-256color"
# Path to your oh-my-zsh installation.
export ZSH="${XDG_CONFIG_HOME}/zsh/oh-my-zsh"

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    ZSH_TMUX_AUTOSTART=false
else
    ZSH_TMUX_AUTOSTART=true
fi

# turn off auto tmux start
ZSH_TMUX_AUTOSTART=false

ZSH_TMUX_AUTOSTART_ONCE=true
ZSH_TMUX_AUTOCONNECT=true
ZSH_TMUX_AUTOQUIT=true

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes

# POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_MODE='awesome-fontconfig'
ZSH_THEME="powerlevel9k/powerlevel9k"

# ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    zsh-autosuggestions
    dotenv
    vi-mode
    tmux
    safe-paste
    colored-man-pages
    git
    zsh-syntax-highlighting
)
HISTFILE=${XDG_CONFIG_HOME}/zsh/.zsh_history_$HOST

setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_BEEP


source $ZSH/oh-my-zsh.sh

# User configuration
setopt extended_glob
bindkey "^[[5~" history-beginning-search-backward
bindkey "^[[6~" history-beginning-search-forward

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
# GREP_OPTIONS="--color=never"
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
# DEFAULT_USER means we dont show user and host in normal shell prompt
DEFAULT_USER=$USER
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
```


## ~/.config/zsh/.zlogin

```bash
# Maintained in linux-init-files.org
logger -t "startup-initfile"  ZLOGIN
# [ -s "$HOME/.rvm/scripts/rvm" ] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
```


## zprofile

1.  ~/.config/zsh/.zprofile

    ```bash
    # Maintained in linux-init-files.org
    logger -t "startup-initfile"  ZPROFILE
    if [ -f ~/.profile ]; then
        emulate sh -c '. ~/.profile'
    fi
    ```

2.  etc/zsh/zprofile

    ```bash
    # Maintained in linux-init-files.org
    # /etc/zsh/zprofile: system-wide .zprofile file for zsh(1).
    #
    # This file is sourced only for login shells (i.e. shells
    # invoked with "-" as the first character of argv[0], and
    # shells invoked with the -l flag.)
    #
    # Global Order: zshenv, zprofile, zshrc, zlogin
    logger -t "startup-initfile"  ETC-ZPROFILE
    ```


## zshenv

1.  etc/zsh/zshenv

    ```bash
    # Maintained in linux-init-files.org
    logger -t "startup-initfile"  ETC-ZSHENV
    if [[ -z "$PATH" || "$PATH" == "/bin:/usr/bin" ]]
    then
        export PATH="/usr/local/bin:/usr/bin:/bin:/usr/games"
        if [ -f /etc/profile ]; then
            emulate sh -c '. /etc/profile'
        fi
    fi
    ```

2.  ~/.config/zsh/.zshenv

    Link this into $HOME

    ```bash
    # Maintained in linux-init-files.org
    logger -t "startup-initfile"  ZSHENV
    if [ -z "$XDG_CONFIG_HOME" ] && [ -d "$HOME/.config" ]
    then
        export XDG_CONFIG_HOME="$HOME/.config"
    fi

    if [ -d "$XDG_CONFIG_HOME/zsh" ]
    then
        export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
    fi
    ```


## Oh-My-Zsh Related

Directory is [here](.oh-my-zsh/).

1.  Aliases ~/.config/zsh/oh-my-zsh/custom/aliases.zsh

    ```conf
    # Maintained in linux-init-files.org
    alias grep="grep -n --color"
    alias hg='history|grep'
    ```

2.  Functions ~/.config/zsh/oh-my-zsh/custom/functions.zsh

    ```bash
    mkc () {
        mkdir -p "$@" && cd "$@" #create full path and cd to it

    }
    ```


# Path


## ~/bin/add-user-paths

```bash
# Maintained in linux-init-files.org
logger -t "startup-initfile"  ADD_USER_PATHS
#export PATH="${HOME}/bin:$HOME/.local/bin:${HOME}/.cargo/bin:./node_modules/.bin:$PATH"
```


# Tmux     :tmux:


## ~/.tmux.conf


### start

```conf
# Maintained in linux-init-files.org
# Change the prefix key to C-a
```


### styles

```conf
set-option -g status on
set-option -g status-interval 1
set-option -g status-justify centre
set-option -g status-keys vi
set-option -g status-position bottom
set-option -g status-style fg=colour136,bg=colour235
set-option -g status-left-length 20
set-option -g status-left-style default
set-option -g status-left "#[fg=green]#H #[fg=black]• #[fg=green,bright]#(uname -r)#[default]"
set-option -g status-right-length 140
set-option -g status-right-style default
set-option -g status-right "#[fg=green,bg=default,bright]#(tmux-mem-cpu-load) "
set-option -ag status-right "#[fg=red,dim,bg=default]#(uptime | cut -f 4-5 -d ' ' | cut -f 1 -d ',') "
set-option -ag status-right " #[fg=white,bg=default]%a%l:%M:%S %p#[default] #[fg=blue]%Y-%m-%d"
set-window-option -g window-status-style fg=colour244
set-window-option -g window-status-style bg=default
set-window-option -g window-status-current-style fg=colour166
set-window-option -g window-status-current-style bg=default

set-option -g default-shell /bin/zsh

```


### keys

```conf
set -g prefix C-a
unbind C-b
bind C-a send-prefix

set -g pane-border-format "#{pane_index} #{pane_title} tty:#{pane_tty}"
set -g pane-border-status bottom

# reload tmux config
bind r source-file ~/.tmux.conf \; display-message "Config reloaded..."

# To copy, left click and drag to highlight text in yellow,
# once you release left click yellow text will disappear and will automatically be available in clibboard
# # Use vim keybindings in copy mode
setw -g mode-keys vi

bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "xclip -i -f -selection primary | xclip -i -selection clipboard"
bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -i -f -selection primary | xclip -i -selection clipboard"
bind -T copy-mode-vi C-j send-keys -X copy-pipe-and-cancel "xclip -i -f -selection primary | xclip -i -selection clipboard"

# Some extra key bindings to select higher numbered windows
bind F1 selectw -t:10
bind F2 selectw -t:11
bind F3 selectw -t:12
bind F4 selectw -t:13
bind F5 selectw -t:14
bind F6 selectw -t:15
bind F7 selectw -t:16
bind F8 selectw -t:17
bind F9 selectw -t:18
bind F10 selectw -t:19
bind F11 selectw -t:20
bind F12 selectw -t:21

# A key to toggle between smallest and largest sizes if a window is visible in
# multiple places
bind F set -w window-size

# Keys to toggle monitoring activity in a window and the synchronize-panes option
bind m set monitor-activity
bind y set synchronize-panes\; display 'synchronize-panes #{?synchronize-panes,on,off}'

bind K kill-session
bind x kill-pane
bind X kill-pane -a
bind c command-prompt -p "window name:" "new-window; rename-window '%%'"
new -d -s0
# neww -d -nemacs 'exec emacsclient -nw ~/.emacs.d/linux-init/inits.org'
# setw -t0:1 aggressive-resize on
# neww -d  -nhtop 'exec htop'

# Use Alt-arrow keys without prefix key to switch panes
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

set -g mouse on
set -g @yank_selection 'clipboard' # 'primary' or 'secondary' or 'clipboard'
set -g @yank_selection_mouse 'clipboard' # or 'primary' or 'secondary'
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'tmux-plugins/tmux-resurrect'

run -b '~/.tmux/plugins/tpm/tpm'

```


## ~/bin/tmux-current-session

```bash
#!/usr/bin/bash
# Maintained in linux-init-files.org
echo "$(tmux list-panes -t "$TMUX_PANE" -F '#S' | head -n1)"
```


## ~/bin/tmux-pane-tty

Written to find the tty for a pane in order to redirect gef context source to a voltron pane

```bash
#!/usr/bin/bash
#Maintained in linux-init-files.org
session="${1:-""}"
[ -z ${session} ] && exit 1
pane_index="${2:-0}"
window="${3:-0}"
tmux list-panes -t "${session}:${window}" -F 'pane_index:#{pane_index} #{pane_tty}' | awk '/pane_index:'"${pane_index}"'/ {print $2 }'
```


# I3 window manager     :i3:i3wm:


## i3wm config


### general

```conf
# Maintained in linux-init-files.org
# This file has been auto-generated by i3-config-wizard(1).
# It will not be overwritten, so edit it as you like.
#
# Should you change your keyboard layout some time, delete
# this file and re-run i3-config-wizard(1).
#

# i3 config file (v4)
#
# Please see https://i3wm.org/docs/userguide.html for a complete reference!

set $mod Mod4

focus_follows_mouse yes
mouse_warping none

# start a terminal
# Use Mouse+$mod to drag floating windows to their wanted position
floating_modifier $mod
# kill focused window
bindsym $mod+q kill

# Font  for window titles. Will also be used by the bar unless a different font
# is used in the bar {} block below.
font pango:monospace 8
# font pango:JetBrains Mono 6
# This font is widely installed, provides lots of unicode glyphs, right-to-left
# text rendering and scalability on retina/hidpi displays (thanks to pango).

# The combination of xss-lock, nm-applet and pactl is a popular choice, so
# they are included here as an example. Modify as you see fit.

# xss-lock grabs a logind suspend inhibit lock and will use i3lock to lock the
# screen before suspend. Use loginctl lock-session to lock your screen.
# ***moved to xprofile
# exec --no-startup-id xss-lock --transfer-sleep-lock -- x-lock-utils lock
# NetworkManager is the most popular way to manage wireless networks on Linux,
# and nm-applet is a desktop environment-independent system tray GUI for it.
# ***moved to xprofile
# exec --no-startup-id nm-applet

# workspace_layout <default|stacking|tabbed>
workspace_layout default

# start dmenu (a program launcher)
# bindsym $mod+d exec dmenu_run
# There also is the (new) i3-dmenu-desktop which only displays applications
# shipping a .desktop file. It is a wrapper around dmenu, so you need that
# installed.
# bindsym $mod+d exec --no-startup-id i3-dmenu-desktop

# reload the configuration file
bindsym $mod+Shift+c reload
# restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
bindsym $mod+Shift+r restart

```


### i3 autostart

```conf
exec --no-startup-id feh --image-bg black  --bg-fill ~/Pictures/Wallpapers/current
exec --no-startup-id nm-applet
```


### i3 workspace

```conf
# change focus
bindsym $mod+o focus left
bindsym $mod+j focus left
bindsym $mod+k focus down
bindsym $mod+l focus up
bindsym $mod+odiaeresis focus right

# alternatively, you can use the cursor keys:
bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right

# move focused window
bindsym $mod+Shift+j move left
bindsym $mod+Shift+k move down
bindsym $mod+Shift+l move up
bindsym $mod+Shift+ö move right

# alternatively, you can use the cursor keys:
bindsym $mod+Shift+Left move left
bindsym $mod+Shift+Down move down
bindsym $mod+Shift+Up move up
bindsym $mod+Shift+Right move right

# split in horizontal orientation
bindsym $mod+h split h

# split in vertical orientation
bindsym $mod+v split v

# enter fullscreen mode for the focused container
bindsym $mod+f fullscreen toggle

# change container layout (stacked, tabbed, toggle split)
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split

# toggle tiling / floating
bindsym $mod+Shift+space floating toggle

# change focus between tiling / floating windows
bindsym $mod+space focus mode_toggle

# focus the parent container
bindsym $mod+a focus parent

bindsym $mod+Shift+s sticky toggle

bindsym $mod+m move workspace to output left
bindsym $mod+Control+m exec i3-display-swap
bindsym $mod+Tab workspace back_and_forth



# focus the child container
#bindsym $mod+d focus child

# Define names for default workspaces for which we configure key bindings later on.
# We use variables to avoid repeating the names in multiple places.
set $ws1 "1:edit"
set $ws2 "2:research"
set $ws3 "3:shell"
set $ws4 "4:browse"
set $ws5 "5:dired"
set $ws6 "6:music"
set $ws7 "7:video"
set $ws8 "8:irc"
set $ws9 "9:steam"
set $ws10 "10"

workspace $ws3 gaps inner 0
workspace $ws3 gaps outer 0



assign [class="Signal"] $ws8
assign [class="Hexchat"] $ws8
assign [class="discord"] $ws8
assign [class="Steam"] $ws9

assign [title="dbg:"] $ws3

# for_window [class="steam_app.*"] fullscreen enable

# switch to workspace
bindsym $mod+1 workspace number $ws1
bindsym $mod+2 workspace number $ws2
bindsym $mod+3 workspace number $ws3
bindsym $mod+4 workspace number $ws4
bindsym $mod+5 workspace number $ws5
bindsym $mod+6 workspace number $ws6
bindsym $mod+7 workspace number $ws7
bindsym $mod+8 workspace number $ws8
bindsym $mod+9 workspace number $ws9
bindsym $mod+0 workspace number $ws10

# move focused container to workspace
bindsym $mod+Shift+1 move container to workspace number $ws1
bindsym $mod+Shift+2 move container to workspace number $ws2
bindsym $mod+Shift+3 move container to workspace number $ws3
bindsym $mod+Shift+4 move container to workspace number $ws4
bindsym $mod+Shift+5 move container to workspace number $ws5
bindsym $mod+Shift+6 move container to workspace number $ws6
bindsym $mod+Shift+7 move container to workspace number $ws7
bindsym $mod+Shift+8 move container to workspace number $ws8
bindsym $mod+Shift+9 move container to workspace number $ws9
bindsym $mod+Shift+0 move container to workspace number $ws10

# resize window (you can also use the mouse for that)
mode "resize" {
# These bindings trigger as soon as you enter the resize mode

# Pressing left will shrink the window’s width.
# Pressing right will grow the window’s width.
# Pressing up will shrink the window’s height.
# Pressing down will grow the window’s height.
bindsym j resize shrink width 10 px or 10 ppt
bindsym k resize grow height 10 px or 10 ppt
bindsym l resize shrink height 10 px or 10 ppt
bindsym odiaeresis resize grow width 10 px or 10 ppt

# same bindings, but for the arrow keys
bindsym Left resize shrink width 10 px or 10 ppt
bindsym Down resize grow height 10 px or 10 ppt
bindsym Up resize shrink height 10 px or 10 ppt
bindsym Right resize grow width 10 px or 10 ppt

# back to normal: Enter or Escape or $mod+r
bindsym Return mode "default"
bindsym Escape mode "default"
bindsym $mod+r mode "default"
}

bindsym $mod+r mode "resize"

```


### i3 volume

```conf

# Use pactl to adjust volume in PulseAudio.
#       set $refresh_i3status killall -SIGUSR1 i3status
set $refresh_i3status killall -SIGUSR1 py3status
bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && $refresh_i3status
bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_i3status
bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status
bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status
```


### i3 screen

```conf
exec command -v brightnessctl && brightnessctl -r
bindsym XF86MonBrightnessUp   exec command -v brightnessctl && brightnessctl s +10 && brightnessctl -s && notify-send -c brightness -t 1000 -u low "Brightness(0-255):$(brightnessctl g)"
bindsym XF86MonBrightnessDown exec command -v brightnessctl && brightnessctl s 10- && brightnessctl -s && notify-send -c brightness -t 1000 -u low "Brightness(0-255):$(brightnessctl g)"
```


### i3 apps

```conf
bindsym $mod+g exec "goldendict \\"`xclip -o -selection clipboard`\\""

bindsym Print exec gnome-screenshot -i

bindsym $mod+Shift+e exec XMODIFIERS= emacs-same-frame
bindsym $mod+Shift+f exec google-chrome --lang=en --disable-session-crashed-bubble
bindsym $mod+Control+a exec pavucontrol
bindsym $mod+Control+Shift+a exec pulse-restart
bindsym $mod+Control+b exec oneterminal "Process-Monitor-bpytop" bpytop
bindsym $mod+Control+c exec conky
bindsym $mod+Control+d exec emacsclient -c -eval '(dired "~")'
bindsym $mod+Control+f exec thunar
bindsym $mod+Control+e exec gdb-run ~/development/projects/C/emacs
bindsym $mod+Control+g exec oneterminal "gdb"
bindsym $mod+Control+v exec ONETERM_PROFILE=voltron ONETERM_TITLE="dbg:voltron" oneterminal $(voltron-session)
bindsym $mod+Control+h exec pidof hexchat || hexchat
bindsym $mod+Control+o exec xmg-neo-rgb-kbd-lights toggle && x-backlight-persist restore
bindsym $mod+Control+p exec oneterminal "Process-Monitor-htop" htop
bindsym $mod+Control+Shift+p exec htop-regexp
bindsym $mod+Control+t exec "notify-send -t 2000 'Opening NEW Terminator instance' && terminator -e zsh"
bindsym $mod+Return exec oneterminal "i3wmterm" ""

#rofi instead of dmenu
bindsym $mod+d exec --no-startup-id "rofi -show drun -font \\"DejaVu 9\\" -run-shell-command '{terminal} -e \\" {cmd}; read -n 1 -s\\"'"

```


### i3 exit, quit, restart, reboot, lock, hibernate, blank, suspend     :hibernate:lock:sleep:blank:blank:restart:exit:reboot:

```conf
set $mode_system System (b) blank (l) lock, (e) logout, (s) suspend, (h) hibernate, (r) reboot, (Shift+s) shutdown
mode "$mode_system" {
bindsym b exec --no-startup-id x-lock-utils screenoff, mode "default"
bindsym l exec --no-startup-id x-lock-utils lock, mode "default"
bindsym e exec --no-startup-id x-lock-utils logout, mode "default"
bindsym s exec --no-startup-id x-lock-utils suspend, mode "default"
bindsym h exec --no-startup-id x-lock-utils hibernate, mode "default"
bindsym r exec --no-startup-id x-lock-utils reboot, mode "default"
bindsym Shift+s exec --no-startup-id x-lock-utils shutdown, mode "default"
# back to normal: Enter or Escape
bindsym Return mode "default"
bindsym Escape mode "default"
}
bindsym $mod+Control+q mode "$mode_system"
```


### i3 bar

```conf
# i3bar
bar {
status_command i3blocks
font pango:JetBrains Sans Mono 10
position top
#mode hide
hidden_state hide
modifier $mod
}
```


### i3 gaps

```conf
# Necessary for i3-gaps to work properly (pixel can be any value)
for_window [class="^.*"] border pixel 1

# Smart Gaps
smart_gaps on

# Smart Borders
smart_borders on

# Set inner/outer gaps
gaps inner 3
gaps outer 0

# Gaps mode
set $mode_gaps Gaps: (o)uter, (i)nner, (h)orizontal, (v)ertical, (t)op, (r)ight, (b)ottom, (l)eft
set $mode_gaps_outer Outer Gaps: +|-|0 (local), Shift + +|-|0 (global)
set $mode_gaps_inner Inner Gaps: +|-|0 (local), Shift + +|-|0 (global)
set $mode_gaps_horiz Horizontal Gaps: +|-|0 (local), Shift + +|-|0 (global)
set $mode_gaps_verti Vertical Gaps: +|-|0 (local), Shift + +|-|0 (global)
set $mode_gaps_top Top Gaps: +|-|0 (local), Shift + +|-|0 (global)
set $mode_gaps_right Right Gaps: +|-|0 (local), Shift + +|-|0 (global)
set $mode_gaps_bottom Bottom Gaps: +|-|0 (local), Shift + +|-|0 (global)
set $mode_gaps_left Left Gaps: +|-|0 (local), Shift + +|-|0 (global)
bindsym $mod+Shift+g mode "$mode_gaps"

mode "$mode_gaps" {
bindsym o      mode "$mode_gaps_outer"
bindsym i      mode "$mode_gaps_inner"
bindsym h      mode "$mode_gaps_horiz"
bindsym v      mode "$mode_gaps_verti"
bindsym t      mode "$mode_gaps_top"
bindsym r      mode "$mode_gaps_right"
bindsym b      mode "$mode_gaps_bottom"
bindsym l      mode "$mode_gaps_left"
bindsym Return mode "$mode_gaps"
bindsym Escape mode "default"
}

mode "$mode_gaps_outer" {
bindsym plus  gaps outer current plus 5
bindsym minus gaps outer current minus 5
bindsym 0     gaps outer current set 0

bindsym Shift+plus  gaps outer all plus 5
bindsym Shift+minus gaps outer all minus 5
bindsym Shift+0     gaps outer all set 0

bindsym Return mode "$mode_gaps"
bindsym Escape mode "default"
}
mode "$mode_gaps_inner" {
bindsym plus  gaps inner current plus 5
bindsym minus gaps inner current minus 5
bindsym 0     gaps inner current set 0

bindsym Shift+plus  gaps inner all plus 5
bindsym Shift+minus gaps inner all minus 5
bindsym Shift+0     gaps inner all set 0

bindsym Return mode "$mode_gaps"
bindsym Escape mode "default"
}
mode "$mode_gaps_horiz" {
bindsym plus  gaps horizontal current plus 5
bindsym minus gaps horizontal current minus 5
bindsym 0     gaps horizontal current set 0

bindsym Shift+plus  gaps horizontal all plus 5
bindsym Shift+minus gaps horizontal all minus 5
bindsym Shift+0     gaps horizontal all set 0

bindsym Return mode "$mode_gaps"
bindsym Escape mode "default"
}
mode "$mode_gaps_verti" {
bindsym plus  gaps vertical current plus 5
bindsym minus gaps vertical current minus 5
bindsym 0     gaps vertical current set 0

bindsym Shift+plus  gaps vertical all plus 5
bindsym Shift+minus gaps vertical all minus 5
bindsym Shift+0     gaps vertical all set 0

bindsym Return mode "$mode_gaps"
bindsym Escape mode "default"
}
mode "$mode_gaps_top" {
bindsym plus  gaps top current plus 5
bindsym minus gaps top current minus 5
bindsym 0     gaps top current set 0

bindsym Shift+plus  gaps top all plus 5
bindsym Shift+minus gaps top all minus 5
bindsym Shift+0     gaps top all set 0

bindsym Return mode "$mode_gaps"
bindsym Escape mode "default"
}
mode "$mode_gaps_right" {
bindsym plus  gaps right current plus 5
bindsym minus gaps right current minus 5
bindsym 0     gaps right current set 0

bindsym Shift+plus  gaps right all plus 5
bindsym Shift+minus gaps right all minus 5
bindsym Shift+0     gaps right all set 0

bindsym Return mode "$mode_gaps"
bindsym Escape mode "default"
}
mode "$mode_gaps_bottom" {
bindsym plus  gaps bottom current plus 5
bindsym minus gaps bottom current minus 5
bindsym 0     gaps bottom current set 0

bindsym Shift+plus  gaps bottom all plus 5
bindsym Shift+minus gaps bottom all minus 5
bindsym Shift+0     gaps bottom all set 0

bindsym Return mode "$mode_gaps"
bindsym Escape mode "default"
}
mode "$mode_gaps_left" {
bindsym plus  gaps left current plus 5
bindsym minus gaps left current minus 5
bindsym 0     gaps left current set 0

bindsym Shift+plus  gaps left all plus 5
bindsym Shift+minus gaps left all minus 5
bindsym Shift+0     gaps left all set 0

bindsym Return mode "$mode_gaps"
bindsym Escape mode "default"
}

```


## i3blocks

1.  config

    ```conf
    [dropbox]
    interval=15
    command=echo  "$(my-i3b-db-status)"
    color=#ffd700

    [power_draw]
    command=echo "Wh:$(awk '{print $1*10^-6 " W"}' /sys/class/power_supply/BAT0/power_now)"
    interval=1
    #color=#ffd700
    color=#00a000

    #[battery]
    #command=my-i3b-battery-status
    #color=#ff8300
    #interval=60

    [bat0]
    command=echo "Ba:$(/usr/share/i3blocks/battery bat0)"
    color=#00a000
    interval=30

    [cpu_usage]
    command= echo "CPU:$(/usr/share/i3blocks/cpu_usage)"
    color=#00a000
    interval=1

    [memory]
    command=echo "Mem:$(/usr/share/i3blocks/memory)"
    color=#00a000
    interval=10

    # [disk]
    # command=echo "D:$(/usr/share/i3blocks/disk)"
    # color=#00a000
    # interval=10

    [uptime]
    command=echo "UT:$(awk '{print int($1/3600)":"int(($1%3600)/60)}' /proc/uptime)"
    interval=60
    color=#00a000

    [ssid]
    command=echo "SSID:$(my-iface-active-ssid)"
    interval=30
    color=#00a000

    #[ssidQ]
    #command=echo "($(my-iface-active-quality)%)"
    #interval=30
    #color=#008000

    [iface]
    command=/usr/share/i3blocks/iface
    color=#00a000
    interval=60

    [weather]
    command=curl -s 'wttr.in/{Grömitz}?format=%l:+%c+%t'
    interval=900
    color=#A4C2F4

    [time]
    command=date +"%a, %d %b: %I:%M"
    interval=60

    [brightness]
    command=echo "Br:$(my-i3b-brightness)"
    color=#FF8300
    interval=2

    [volume]
    command=echo "V:$(/usr/share/i3blocks/volume)"
    interval=1
    color=#FF8300

    ```

2.  i3blocks utilities

    1.  ~/bin/my-i3b-battery-status

        ```bash
        #!/usr/bin/bash
        #Maintained in linux-init-files.org
        b=`acpi | grep -m 1 -i "remaining\|charging" | sed 's/.*Battery....//I'`
        if [ -z "$b" ]; then
            echo "charged";
        else
            echo $b;
        fi
        ```

    2.  ~/bin/my-i3b-db-status

        ```bash
        #!/usr/bin/bash
        #Maintained in linux-init-files.org
        if pidof dropbox > /dev/null ; then
            stat=$(dropbox status | sed -n 1p)
            echo "DB:${stat}"; echo "";
        else
            if command -v dropbox > /dev/null; then
                echo "Restart Dropbox.."
                #dropbox start &> /dev/null &
            fi
        fi
        ```

    3.  ~/bin/my-i3b-brightness

        return the brightness %

        ```bash
        #!/usr/bin/bash
        #Maintained in linux-init-files.org
        #echo "B:$(echo "scale=2;100 / "" * "$(brightnessctl g)"" | bc |  sed 's!\..*$!!')%"
        if command -v brightnessctl &> /dev/null; then
            echo "$((1+((100000/$(brightnessctl m))*$(brightnessctl g))/1000))%"
        else
            echo "N/A"
        fi
        ```


## i3 utility scripts


### ~/bin/i3-display-swap

<https://i3wm.org/docs/user-contributed/swapping-workspaces.html>

```bash
#!/usr/bin/bash
# Maintained in linux-init-files.org

DISPLAY_CONFIG=($(i3-msg -t get_outputs | jq -r '.[]|"\(.name):\(.current_workspace)"'))

for ROW in "${DISPLAY_CONFIG[@]}"
do
    IFS=':'
    read -ra CONFIG <<< "${ROW}"
    if [ "${CONFIG[0]}" != "null" ] && [ "${CONFIG[1]}" != "null" ]; then
        echo "moving ${CONFIG[1]} right..."
        i3-msg -- workspace --no-auto-back-and-forth "${CONFIG[1]}"
        i3-msg -- move workspace to output right
    fi
done
```


## add-ons


# Vim


## ~/.vimrc

```conf
" Maintained in linux-init-files.org
set nocompatible              " be iMproved, required
filetype off                  " required

call plug#begin('~/.vim/plugged')

Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'christoomey/vim-tmux-navigator'
Plug 'vim-scripts/mru.vim'
" Plug 'ervandew/supertab'

call plug#end()

set nonu nu ic is hls

map ; :Files<CR>

" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

nnoremap  <silent>   <tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bnext<CR>
nnoremap  <silent> <s-tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bprevious<CR>

" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

cnoreabbrev <expr> tn getcmdtype() == ":" && getcmdline() == 'tn' ? 'tabnew' : 'tn'
cnoreabbrev <expr> th getcmdtype() == ":" && getcmdline() == 'th' ? 'tabp' : 'th'
cnoreabbrev <expr> tl getcmdtype() == ":" && getcmdline() == 'tl' ? 'tabn' : 'tl'
cnoreabbrev <expr> te getcmdtype() == ":" && getcmdline() == 'te' ? 'tabedit' : 'te'

nnoremap <F5> :buffers<CR>:buffer<Space>

map <C-o> :NERDTreeToggle<CR>

set shortmess+=A
set splitbelow
set splitright

```


# ripgrep


## ~/.ignore

```conf
# Maintained in linux-init-files.org
*~
.git
cache
.cache
```


## ~/.ripgreprc

```conf

# Maintained in linux-init-files.org
# Don't let ripgrep vomit really long lines to my terminal, and show a preview.
--max-columns=150

# Set the colors.
--color=never
--colors=line:none
--colors=line:style:bold

# Because who cares about case!?
--smart-case
```


# Conky


## ~/.config/conky/conky.conf

```conky
--[[
Conky, a system monitor, based on torsmo

Any original torsmo code is licensed under the BSD license

All code written since the fork of torsmo is licensed under the GPL

Please see COPYING for details

Copyright (c) 2004, Hannu Saransaari and Lauri Hakkarainen
Copyright (c) 2005-2019 Brenden Matthews, Philip Kovacs, et. al. (see AUTHORS)
All rights reserved.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

conky.config = {
    alignment = 'top_left',
    background = false,
    border_width = 1,
    cpu_avg_samples = 2,
    default_color = 'white',
    default_outline_color = 'white',
    default_shade_color = 'white',
    double_buffer = true,
    draw_borders = false,
    draw_graph_borders = true,
    draw_outline = false,
    draw_shades = false,
    extra_newline = false,
    font = 'DejaVu Sans Mono:size=8',
    gap_x = 60,
    gap_y = 60,
    minimum_height = 5,
    minimum_width = 5,
    net_avg_samples = 2,
    no_buffers = true,
    out_to_console = false,
    out_to_ncurses = false,
    out_to_stderr = false,
    out_to_x = true,
    own_window = true,
    own_window_class = 'Conky',
    own_window_type = 'desktop',
    show_graph_range = false,
    show_graph_scale = false,
    stippled_borders = 0,
    update_interval = 1.0,
    uppercase = false,
    use_spacer = 'none',
    use_xft = true,
}

conky.text = [[
${color grey}Info:$color ${scroll 32 Conky $conky_version - $sysname $nodename $kernel $machine}
$hr
${color grey}Uptime:$color $uptime
${color grey}Frequency (in MHz):$color $freq
${color grey}Frequency (in GHz):$color $freq_g
${color grey}RAM Usage:$color $mem/$memmax - $memperc% ${membar 4}
${color grey}Swap Usage:$color $swap/$swapmax - $swapperc% ${swapbar 4}
${color grey}CPU Usage:$color $cpu% ${cpubar 4}
${color grey}Processes:$color $processes  ${color grey}Running:$color $running_processes
$hr
${color grey}File systems:
 / $color${fs_used /}/${fs_size /} ${fs_bar 6 /}
${color grey}Networking:
Up:$color ${upspeed} ${color grey} - Down:$color ${downspeed}
$hr
${color grey}Name              PID     CPU%   MEM%
${color lightgrey} ${top name 1} ${top pid 1} ${top cpu 1} ${top mem 1}
${color lightgrey} ${top name 2} ${top pid 2} ${top cpu 2} ${top mem 2}
${color lightgrey} ${top name 3} ${top pid 3} ${top cpu 3} ${top mem 3}
${color lightgrey} ${top name 4} ${top pid 4} ${top cpu 4} ${top mem 4}
]]
```


# Radare

Reverse engineering packges [radare2](https://radare.gitbooks.io/radare2book/content/first_steps/intro.html).


## ~/.config/radare2/radare2rc

```conf
e scr.utf8=true
e scr.utf8.curvy=true
e dbg.bep=main
```


# Programming Related     :programming:


## gdb     :gdb:


### scripts

1.  ~/.gdbinit

    ```conf
    # Maintained in linux-init-files.org

    set auto-load safe-path /
    set auto-load local-gdbinit on
    set history save on
    set history filename ~/.gdb_history
    set history size 32768
    set history expansion on

    set print pretty on

    set print symbol-filename on

    set pagination off
    set confirm off

    set print address off
    set print symbol-filename off

    define lsource
    list *$rip
    end

    define il
    info locals $arg0
    end

    define ila
    info locals
    end


    define hook-quit
    shell tmux kill-session -t "$(voltron-session)" &> /dev/null
    shell tmux kill-session -t "$(tmux-current-session)" &> /dev/null
    end

    #### Initialise GEF Session
    define gef-init

    source ~/bin/thirdparty/gef/gef.py

    define f
    frame $arg0
    context
    end

    define hook-up
    context
    end

    define hook-down
    context
    end

    # gef save updates ~/.gef.rc
    # gef config context.layout "legend -regs stack -args source -code -threads -trace -extra -memory"
    # gef config context.nb_lines_code 13
    # gef config context.nb_lines_code_prev 6
    # gef config context.nb_lines_stack 4
    tmux-setup
    # context
    # shell tmux select-pane -t .0

    end

    #### Initialise Voltron Session
    define voltron-init
    source /home/rgr/.local/lib/python3.9/site-packages/voltron/entry.py

    alias vtty = shell tmux-pane-tty voltron 4

    define voltron-source-tty
    shell tmux-pane-tty
    end

    voltron init

    end

    #### Initialise utility extensions
    define ext-init
    gef-init
    voltron-init
    end

    ```

2.  python


### desktop

1.  tmux gdb setup scripts     :tmux:

    1.  ~/bin/gdb-session

        Create a session but let someone else do the attach

        ```bash
        #!/usr/bin/bash
        # Maintained in linux-init-files.org
        directory="$(realpath -s "${1:-`pwd`}")"
        cd "${directory}"
        session="${2:-${directory//[^[:alnum:]]/}}"
        window=${2:-"0"}
        pane=${3:-"0"}
        if ! tmux has-session -t "${session}" &> /dev/null; then
            tmux new-session -c ${directory} -d -s "${session}"
            tmux send-keys -t  "${session}:${window}.$(expr $pane + 0)" "gdb"  C-m
        fi
        echo "$session"
        ```

    2.  ~/bin/gdb-run

        ```bash
        #!/usr/bin/bash
        # Maintained in linux-init-files.org
        directory="${1:-`pwd`}"
        session="${2}"
        ONETERM_PROFILE=gdb ONETERM_TITLE="dbg:gdb"  oneterminal "$(gdb-session "${directory}" "${session}")" &
        ```

    3.  DONE 19:33 change gdb-session to use directory for session name unless passed in specifically


### gef     :gef:

[GEF](https://github.com/hugsy/gef) provided additional features to GDB using the Python API to assist during the process of dynamic analysis and exploit development

1.  ~/.gef.rc  NOT TANGLED -  as can save it from gef

    The default gef config

    ```conf
    [context]
    clear_screen = True
    enable = True
    grow_stack_down = False
    ignore_registers =
    layout = legend regs stack code args source memory threads trace extra
    nb_lines_backtrace = 10
    nb_lines_code = 6
    nb_lines_code_prev = 3
    nb_lines_stack = 8
    nb_lines_threads = -1
    peek_calls = True
    peek_ret = True
    redirect =
    show_registers_raw = False
    show_stack_raw = False
    use_capstone = False

    [dereference]
    max_recursion = 7

    [entry-break]
    entrypoint_symbols = main _main __libc_start_main __uClibc_main start _start

    [gef-remote]
    clean_on_exit = False

    [gef]
    autosave_breakpoints_file =
    debug = False
    disable_color = False
    extra_plugins_dir = ~/bin/thirdparty/gef-extras/scripts
    follow_child = True
    readline_compat = False
    tempdir = /tmp/gef

    [got]
    function_not_resolved = yellow
    function_resolved = green

    [heap-analysis-helper]
    check_double_free = True
    check_free_null = False
    check_heap_overlap = True
    check_uaf = True
    check_weird_free = True

    [heap-chunks]
    peek_nb_byte = 16

    [hexdump]
    always_show_ascii = False

    [highlight]
    regex = False

    [ida-interact]
    host = 127.0.0.1
    port = 1337
    sync_cursor = False

    [pattern]
    length = 40

    [pcustom]
    max_depth = 4
    struct_path = ~/bin/thirdparty/gef-extras/structs

    [process-search]
    ps_command = /usr/bin/ps auxww

    [syscall-args]
    path = ~/bin/thirdparty/gef-extras/syscall-tables

    [theme]
    address_code = red
    address_heap = green
    address_stack = pink
    context_title_line = gray
    context_title_message = cyan
    default_title_line = gray
    default_title_message = cyan
    dereference_base_address = cyan
    dereference_code = gray
    dereference_register_value = bold blue
    dereference_string = yellow
    disassemble_current_instruction = green
    registers_register_name = blue
    registers_value_changed = bold red
    source_current_line = green
    table_heading = blue

    [trace-run]
    max_tracing_recursion = 1
    tracefile_prefix = ./gef-trace-

    [unicorn-emulate]
    show_disassembly = False
    verbose = False

    [aliases]
    pf = print-format
    status = process-status
    binaryninja-interact = ida-interact
    bn = ida-interact
    binja = ida-interact
    lookup = scan
    grep = search-pattern
    xref = search-pattern
    flags = edit-flags
    mprotect = set-permission
    emulate = unicorn-emulate
    cs-dis = capstone-disassemble
    sc-search = shellcode search
    sc-get = shellcode get
    asm = assemble
    ps = process-search
    start = entry-break
    nb = name-break
    ctx = context
    telescope = dereference
    pattern offset = pattern search
    hl = highlight
    highlight ls = highlight list
    hll = highlight list
    hlc = highlight clear
    highlight set = highlight add
    hla = highlight add
    highlight delete = highlight remove
    highlight del = highlight remove
    highlight unset = highlight remove
    highlight rm = highlight remove
    hlr = highlight remove
    fmtstr-helper = format-string-helper
    dps = dereference
    dq = hexdump qword
    dd = hexdump dword
    dw = hexdump word
    dc = hexdump byte
    dt = pcustom
    bl = info breakpoints
    bp = break
    be = enable breakpoints
    bd = disable breakpoints
    bc = delete breakpoints
    tbp = tbreak
    tba = thbreak
    pa = advance
    ptc = finish
    t = stepi
    p = nexti
    g = gef run
    uf = disassemble
    screen-setup = tmux-setup
    ```


### voltron     :voltron:

<https://github.com/snare/voltron>

1.  voltron panes

    add voltron panes to an existing session

    1.  ~/bin/voltron-panes-h

        ```bash
        #!/usr/bin/bash
        # Maintained in linux-init-files.org
        session=${1:-"voltron"}
        window=${2:-"0"}
        pane=${3:-"0"}
        tmux send-keys -t "${session}:${window}.${pane}" "voltron v disasm" C-m
        tmux splitw -h -t "${session}:${window}.$(expr $pane + 0)" "voltron v c ila --lexer gdb_intel"
        tmux splitw -h -t "${session}:${window}.$(expr $pane + 1)"
        tmux splitw -v -t "${session}:${window}.$(expr $pane + 1)" "voltron v register"
        tmux splitw -v -t "${session}:${window}.$(expr $pane + 1)" "voltron v breakpoints"
        ```

2.  ~/bin/voltron-session

    ```bash
    #!/usr/bin/bash
    # Maintained in linux-init-files.org
    session="${1:-voltron}"
    if ! tmux has-session -t "${session}" &> /dev/null; then
        tmux new-session -d -s "${session}" &> /dev/null
        voltron-panes-h "${session}"
    fi
    echo "${session}"
    ```


### python     :python:


## python


### pyvenv  <https://github.com/pyenv/pyenv#installation>

1.  add pyenv to path

    ```bash
    export PYENV_ROOT="${HOME}/.pyenv"
    export PATH="${HOME}/.pyenv/bin":"${PATH}"
    ```

2.  [Eval](#orgeb7d002) pyenv init from bash\_profile in order to set python version

    ```bash
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
    ```

    ```bash
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
    ```

    Added to PATH in [~/.profile](#orgbbb8554)


### Debuggers     :debuggers:

1.  pdb     :pdb:

    <https://docs.python.org/3/library/pdb.html> The official python debugger [/home/rgr/development/projects/Python/debugging/pdb](file:///home/rgr/development/projects/Python/debugging/pdb)

2.  ipdb     :ipdb:

    <https://pypi.org/project/ipdb/>

    1.  installing

        ```bash
        pip install ipdb
        ```

    2.  Better Python Debugging

        <https://hasil-sharma.github.io/2017-05-13-python-ipdb/>

    3.  ~/.ipdb

        ```conf
        # Maintained in linux-init-files.org
        context=5
        ```


# PGP/GNUPG/GPG


## ~/.gnupg/gpg.conf

```gpg
# Maintained in linux-init-files.org
use-agent
```


## ~/.gnupg/gpg-agent.conf

```conf
# Maintained in linux-init-files.org
#gpg-preset-passphrase
allow-preset-passphrase
pinentry-program /usr/bin/pinentry
max-cache-ttl 86400
default-cache-ttl 86400
max-cache-ttl-ssh 86400
default-cache-ttl-ssh 86400
enable-ssh-support
```


## ~/.profile

```bash
export USER_STARTX_START=
```


# systemd


## DONE lock when lid closed


### TODO ~/.config/systemd/user/lidlock.service

```conf
# Maintained in linux-init-files.org
[Unit]
Description=i3lock on suspend
After=sleep.target

[Service]
Type=forking
Environment=DISPLAY=:0
#ExecStart=/usr/bin/i3lock -d -c 000000

[Install]
WantedBy=sleep.target
```


# ACPI


## power status


### acpid events

You must copy these into [*etc/acpi/events*](file:///etc/acpi/events/) if you have an encrypted home directory else symlink.

1.  /etc/acpi/events/user-powerstate

    ```conf
    # Maintained in linux-init-files.org
    # /etc/acpi/events/user-powerstate
    # Called when the user connects ac power to us
    #
    event=ac_adapter.*
    action=/etc/acpi/actions/user-powerstate.sh
    ```

2.  /etc/acpi/events/xmg-neo-powerstate

    ```conf
    # Maintained in linux-init-files.org
    # /etc/acpi/events/xmg-neo-powerstate
    # Called when the user connects ac power to us
    #
    event=ac_adapter.*
    action=/etc/acpi/actions/xmg-neo-powerstate.sh
    ```


### acpid actions

You must copy these into [/etc/acpi/actions](file:///etc/acpi/actions) if you have an encrypted home directory else symlink.

1.  /etc/acpi/actions/user-powerstate.sh

    ```bash
    #!/usr/bin/bash
    # Maintained in linux-init-files.org
    # /etc/acpi/actions/user-powerstate
    . /usr/share/acpi-support/power-funcs
    . /usr/share/acpi-support/policy-funcs
    getState
    echo "export POWERSTATE=${STATE}"  > /tmp/user-acpi-powerstate
    export POWERSTATE=$STATE
    ```

2.  /etc/acpi/actions/xmg-neo-powerstate.sh

    ```bash
    #!/usr/bin/bash
    # Maintained in linux-init-files.org
    # /etc/acpi/actions/xmg-neo-powerstate
    . /usr/share/acpi-support/power-funcs
    . /usr/share/acpi-support/policy-funcs
    getState
    echo $( [ $STATE ="AC" ] && echo 0 || echo 1 ) > /sys/class/leds/qc71_laptop::lightbar/brightness

    ```

    remembering to restart acpid :

    ```bash
    sudo systemctl restart acpid
    ```


# Email Related


## mu4e  - mu for Emacs

[mu4e](https://www.djcbsoftware.nl/code/mu/mu4e.html), a Maildir based email client for Emacs, is configured in my [emacs-config](https://github.com/rileyrg/Emacs-Customisations)


## Maildir sync using [mbsync](https://wiki.archlinux.org/index.php/Isync) inspired by the [SystemCrafters](https://www.youtube.com/watch?v=yZRyEhi4y44&ab_channel=SystemCrafters&loop=0) video.

maildir sync using mbsync


### install isync and mu4e

mu4e includes [mu](https://www.djcbsoftware.nl/code/mu/mu4e/Indexing-your-messages.html) for indexing.

```bash
sudo apt install isync mu4e
```


### mbsync config

Note the [PassCmd](https://wiki.archlinux.org/index.php/Isync) - since I use gpg then that's the way to go.

```conf
# Maintained in linux-init-files.org
Create  Both
Expunge Both
SyncState *

IMAPAccount gmx
Host imap.gmx.com
User rileyrg@gmx.de
PassCmd "pass Email/gmx/apps/mbsync"
SSLType IMAPS
CertificateFile /etc/ssl/certs/ca-certificates.crt
PipelineDepth 1

IMAPStore gmx-remote
Account gmx

MaildirStore gmx-local
Path ~/Maildir/gmx/
Inbox ~/Maildir/gmx/INBOX
SubFolders Legacy

Channel gmx-inbox
Master :gmx-remote:"INBOX"
Slave :gmx-local:"INBOX"

Channel gmx-sent
Master :gmx-remote:"Gesendet"
Slave :gmx-local:"Sent"

Channel gmx-learning
Master :gmx-remote:"Learning"
Slave :gmx-local:"Learning"

Channel gmx-drafts
Master :gmx-remote:"Entw&APw-rfe"
Slave :gmx-local:"Drafts"

Channel gmx-bin
Master :gmx-remote:"Gel&APY-scht"
Slave :gmx-local:"Bin"

Channel gmx-spam
Master :gmx-remote:"Spamverdacht"
Slave :gmx-local:"Spam"

Channel gmx-archive
Master :gmx-remote:"Archiv"
Slave :gmx-local:"Archive"

Group gmx
Channel gmx-inbox
Channel gmx-sent
Channel gmx-drafts
Channel gmx-bin
Channel gmx-spam
Channel gmx-archive

Group gmx-special-interest
Channel gmx-learning

IMAPAccount gmail
Host imap.gmail.com
User rileyrg@gmail.com
PassCmd "pass Email/gmail/apps/mbsync"
SSLType IMAPS
CertificateFile /etc/ssl/certs/ca-certificates.crt
PipelineDepth 32

IMAPStore gmail-remote
Account gmail

MaildirStore gmail-local
Path ~/Maildir/gmail/
Inbox ~/Maildir/gmail/INBOX
SubFolders Legacy

Channel gmail-inbox
Master :gmail-remote:"INBOX"
Slave :gmail-local:"INBOX"

Channel gmail-sent
Master :gmail-remote:"[Google Mail]/Sent Mail"
Slave :gmail-local:"Sent"

Channel gmail-drafts
Master :gmail-remote:"[Google Mail]/Drafts"
Slave :gmail-local:"Drafts"

Channel gmail-bin
Master :gmail-remote:"[Google Mail]/Bin"
Slave :gmail-local:"Bin"

Channel gmail-spam
Master :gmail-remote:"[Google Mail]/Spam"
Slave :gmail-local:"Spam"

Channel gmail-archive
Master :gmail-remote:"[Google Mail]/All Mail"
Slave :gmail-local:"Archive"

Channel gmail-gmx-archive
Master :gmail-remote:"[Google Mail]/All Mail"
Slave :gmx-local:"gmail/Archive"

Group gmail
Channel gmail-inbox
Channel gmail-sent
Channel gmail-drafts
Channel gmail-bin
Channel gmail-spam
Channel gmail-archive

Group gmail-gmx
Channel gmail-gmx-archive

```


### sync and index

```bash
cd ~
mkdir -p ~/Maildir/gmail
mkdir -p ~/Maildir/gmx
mbsync gmail gmx
mu init --maildir=~/Maildir --my-address="riley**@gmx.de" --my-address="riley**@gmail.com"
mu index
```


### mbsync services

1.  ~/.config/systemd/user/mbsync.timer

    ```conf
    [Unit]
    Description=Mailbox synchronization timer

    [Timer]
    OnBootSec=15m
    OnUnitActiveSec=60m
    Unit=mbsync.service

    [Install]
    WantedBy=timers.target
    ```

2.  ~/.config/systemd/user/mbsync.service

    ```conf
    [Unit]
    Description=Mailbox synchronization service

    [Service]
    Type=oneshot
    ExecStart=/home/rgr/bin/getmails
    ```

    and activate them

    ```bash
    systemctl --user enable mbsync.timer
    systemctl --user start mbsync.timer
    ```


## ~/bin/getmails

```bash
#!/usr/bin/bash
# Maintained in linux-init-files.org
if [ $# -eq 0 ]
then
    mbsync -a
else
    mbsync "$@"
fi
pidof mu &> /dev/null || mu index
```


# bin


## one commands

if it exists jump to it else start it


### ~/bin/oneinstance

```bash
#!/bin/bash
#Maintained in linux-init-files.org
# oneinstance exename pname  winclass
exename=$1;pname="${2:-"$exename"}";winclass={$3:-${pname}};
if ! pidof "$pname"; then
    ${exename}
else
    xdotool windowactivate $(head -n 1 <<< $(xdotool search --name "${winclass}"))
fi
```


### ~/bin/oneterminal

```bash
#!/usr/bin/bash
#Maintained in linux-init-files.org

sessionname="${1:-`pwd`}"
title="${ONETERM_TITLE:-${sessionname}}"
#sessionname="${sessionname//[^[:alnum:]]/}"
script="${2}"
tflags="${3}"

profile="${ONETERM_PROFILE:-"$(hostname)"}"

WID=`xdotool search --name "^${title}$" | head -1`
if [ -z "$WID" ]; then
    terminator -T "${title}" -p "${profile}" ${tflags} -e "tmux new-session -A -s ${sessionname} ${script}"
else
    if ! tmux has-session -t  "${sessionname}"; then
        tmux attach -t "${sessionname}"
    fi
    xdotool windowactivate $WID
fi
exit 0
```


### ~/bin/pop-window

```bash
#!/usr/bin/bash
#Maintained in linux-init-files.org
WID=`xdotool search --name "^${title}$" | head -1`
[ -z "${WID}" ] || xdotool windowactivate "${WID}"
```


## network interface utilities

1.  ~/bin/my-iface-active-query

    ```bash
    #!/usr/bin/bash
    #Maintained in linux-init-files.org
    nmcli device show ${IFACE_ACTIVE:-$(my-iface-active)} | grep -i -m 1 "${1:-".*"}.*:" | awk '{print $2}'
    ```

2.  ~/bin/my-iface-active

    ```bash
    #!/usr/bin/bash
    #Maintained in linux-init-files.org
    IFACE_ACTIVE="$(nmcli device show | grep -m 1 "GENERAL.DEVICE" | awk '{print $2}')"
    export IFACE_ACTIVE
    echo $IFACE_ACTIVE
    ```

3.  ~/bin/my-iface-active-ssid

    ```bash
    #!/usr/bin/bash
    #Maintained in linux-init-files.org
    my-iface-active-query "GENERAL.CONNECTION"
    ```

4.  ~/bin/my-iface-active-ipaddr

    ```bash
    #!/usr/bin/bash
    #Maintained in linux-init-files.org
    my-iface-active-query "IP4.ADDRESS"
    ```

5.  ~/bin/my-iface-active-quality

    ```bash
    #!/usr/bin/bash
    #Maintained in linux-init-files.org
    my-iface-active-query "GENERAL.STATE"
    ```


## ~/bin/confirm-suspend

```bash
#!/usr/bin/bash
#Maintained in linux-init-files.org
delay=10;
message="Almost out of juice."
while [ "$#" -gt 0 ]; do
    case $1 in
        -d|--delay) delay="${2}";shift;;
        -m|--message) message="${2} ";shift;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

zenity --question --text="${message}Proceed to suspend in ${delay}s?"
if [ $? = 0 ]; then
    sleep "$delay" && systemctl suspend
else
    exit
fi
```


## ~/bin/dropbox-start-once

```bash
#!/usr/bin/bash
# Maintained in linux-init-files.org
if pidof dropbox > /dev/null ; then
    echo "Dropbox is already running"
else
    if command -v dropbox &> /dev/null; then
        echo "Starting Dropbox.."
        if [ "$1" = "async" ]; then
            dropbox start &> /dev/null &
        else
            dropbox start &> /dev/null
        fi
    fi
fi
```


## ~/bin/edit

```bash
#!/usr/bin/bash
# Maintained in linux-init-files.org
${VISUAL:-${EDITOR:-vi}} "${@}"
```


## ~/bin/eman

Use emacs for manpages if it's running might be an idea set an alias such as 'alias man=eman'

```bash
#!/usr/bin/bash
# Maintained in linux-init-files.org
mp=${1:-"man"}
pgrep -x emacs > /dev/null && ( (emacsclient -c -e "(manual-entry \"-a ${mp}\"))" &> /dev/null) & ) || /usr/bin/man "$@"
```


## ~/bin/expert-advice

```bash
#!/usr/bin/bash
# Maintained in linux-init-files.org
f=$(command -v fortune &>/dev/null && fortune || echo "I don't need to study a subject to have my own truths. Because own truths ARE a thing in 2020.")
if [ "$1" = "t" ]
then
    echo $f | xclip -i -selection clipboard
fi
echo $f
```


## ~/bin/extract-debug-info

strip debug info and store elsewhere

```bash
#!/usr/bin/bash
# Maintained in linux-init-files.org
scriptdir=`dirname ${0}`
scriptdir=`(cd ${scriptdir}; pwd)`
scriptname=`basename ${0}`

set -e

function errorexit()
{
    errorcode=${1}
    shift
    echo $@
    exit ${errorcode}
}

function usage()
{
    echo "USAGE ${scriptname} <tostrip>"
}

tostripdir=`dirname "$1"`
tostripfile=`basename "$1"`


if [ -z ${tostripfile} ] ; then
    usage
    errorexit 0 "tostrip must be specified"
fi

cd "${tostripdir}"

debugdir=.debug
debugfile="${tostripfile}.debug"

if [ ! -d "${debugdir}" ] ; then
    echo "creating dir ${tostripdir}/${debugdir}"
    mkdir -p "${debugdir}"
fi
echo "stripping ${tostripfile}, putting debug info into ${debugfile}"
objcopy --only-keep-debug "${tostripfile}" "${debugdir}/${debugfile}"
strip --strip-debug  "${tostripfile}"
#objcopy --add-gnu-debuglink="${debugdir}/${debugfile}" "${tostripfile}"
chmod -x "${debugdir}/${debugfile}"

```


## ~/bin/htop-regexp

```bash
#!/usr/bin/bash
#Maintained in linux-init-files.org
filter="${1:-"$(zenity --entry --text "HTop filter" --title "htop regexp")"}"
session="${2:-"htop-filter-${filter//[^[:alnum:]]/}"}"
pids=$(ps aux | awk '/'"${filter}"'/ {print $2}' | xargs | sed -e 's/ /,/g')
if tmux has-session -t "${session}"; then
    tmux kill-session -t "${session}"
    sleep 0.1
fi
tmux new-session -d -s "${session}" "htop -p $pids"
sleep 0.1
ONETERM_TITLE="filtered htop:${filter}" ONETERM_PROFILE="Process-Monitor-htop" oneterminal "${session}"
```


## ~/bin/make-compile\_commands

```bash
#!/usr/bin/bash
#Maintained in linux-init-files.org
make --always-make --dry-run \
    | grep -wE 'gcc|g++' \
    | grep -w '\-c' \
    | jq -nR '[inputs|{directory:".", command:., file: match(" [^ ]+$").string[1:]}]' \
         > compile_commands.json
```


## ~/bin/pulse-restart

restart pulseaudio

```bash
#!/usr/bin/bash
# Maintained in linux-init-files.org
pulseaudio -k &> /dev/null
pulseaudio -D &> /dev/null
start-pulseaudio-x11
```


## ~/bin/random-man-page

```bash
#!/usr/bin/bash
#Maintained in linux-init-files.org
man $(find /usr/share/man/man1 -type f | sort -R | head -n1)
```


## ~/bin/remove-broken-symlinks

```bash
#!/usr/bin/bash
#Maintained in linux-init-files.org
find -L . -name . -o -type d -prune -o -type l -exec rm {} +
```


## ~/bin/remove-conflicted-copies

```bash
#!/usr/bin/bash
#Maintained in linux-init-files.org
if [ "$1" == "--f" ]; then
    find ~/Dropbox/ -path "*(*'s conflicted copy [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*" -exec rm -f {} \;
    find ~/Dropbox/ -path "*(*s in Konflikt stehende Kopie [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*" -exec rm -f {} \;

else
    echo "add --f to force deletion of conflicted copies"
    find ~/Dropbox/ -path "*(*'s conflicted copy [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*" -print
    find ~/Dropbox/ -path "*(*s in Konflikt stehende Kopie [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*" -print
fi
```


## ~/bin/resgithub.sh

[resgithub.sh - reset local and remote git repo](https://github.com/rileyrg/resgithub)

```bash
#!/usr/bin/bash
#Maintained in resgithub.org
tconfig=$(mktemp)
texclude=$(mktemp)
commitmsg=${1:-"git repository initialised"}
if [ -f .git/config ]; then
    cp .git/config "$tconfig"
    cp .git/info/exclude "$texclude"
    rm -rf .git
    git init .
    mv "$tconfig" .git/config
    mv "$texclude" .git/info/exclude
    git add .
    git commit -a -m "$commitmsg"
    git push -f
else
    echo "test Warning: No git config file found. Aborting.";exit;
fi
```


## ~/bin/sharemouse

```bash
#!/usr/bin/bash
#Maintained in linux-init-files.org
exec ssh -X ${1-192.168.2.100} x2x -east -to :0
```


## ~/bin/sys-logger

Only log to syslog if MY\_LOGGER -T "STARTUP-INITFILE" \_ON is set

```bash
#!/usr/bin/bash
# Maintained in linux-init-files.org
[ -z "${MY_LOGGER} -T "STARTUP-INITFILE" _ON" ] || /usr/bin/logger -t "startup-initfile"  "$@"
```


## ~/bin/upd

update sw

```bash
#!/usr/bin/bash
# Maintained in linux-init-files.org
export DEBIAN_FRONTEND=noninteractive
sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean -y && sudo apt autoclean -y
```


## XMG Neo 15 Specifics


### ~/bin/xmg-neo-rgb-kbd-lights

See [XMGNeo 15 keyboard backlight controller](https://github.com/pobrn/ite8291r3-ctl) for the controller code.

```bash
#!/usr/bin/bash
#Maintained in linux-init-files.org

sf="$HOME/.xmg-neo-kbd"

if ! command -v ite8291r3-ctl &> /dev/null;  then
    echo "xmg rgb keyboard light controller not found. install ite8291r3-ctl?"
    exit 1;
fi

save() (
    echo "$lightstatus:$brightness:$color:$rgb" > "$sf"
)

restore(){
    lightstatus="on";brightness=20;rgb="";color="silver";
    if [ -f "$sf" ]; then
        _ifs="$IFS";IFS=':' read -r lightstatus brightness color rgb < "$sf";IFS="$_ifs";
    fi
}

update(){
    if [ "$lightstatus" = "off" ]; then
        ite8291r3-ctl off
    else
        ite8291r3-ctl monocolor $([ -n "$color" ] && echo "--name $color" || echo "--rgb $rgb") --brightness "$brightness" &> /dev/null
    fi
    save
}

restore

case "${1:-on}" in
    on)
        lightstatus="on"
        update
        ;;
    off)
        lightstatus="off"
        update
        ;;
    sleep)
        # use sleep to turn off light for less noise when not interacting with the keyboard
        ite8291r3-ctl brightness 0
        ;;
    wake)
        update
        ;;
    get-brightness)
        ite8291r3-ctl query --brightness
        ;;
    set-brightness)
        brightness=${2:-"$brightness"}
        if [ -z "${brightness##*[!0-9]*}" ]; then
            brightness=50
        elif (( $brightness > 50 )); then
            brightness=50
        fi
        update
        ;;
    set-color)
        color=${2:-"$color"};rgb="";
        update
        ;;
    set-rgb)
        rgb=${2:-"$rgb"};color="";
        update
        ;;
    toggle)
        lightstatus=$( [ $lightstatus = "off" ] && echo "on" || echo "off")
        update
        ;;
    inc)
        ;;
    dec)
        ;;
    *)
        echo "Usage:${0} on|off|sleep|wake|set-brightness|get-brightness|set-color|set-rgb|inc v|dec v"
        exit 1
        ;;
esac

exit 0
```


### test

```bash
xmg-neo-rgb-kbd-lights on
```

```bash
xmg-neo-rgb-kbd-lights off
```

```bash
xmg-neo-rgb-kbd-lights set-brightness 50
```

```bash
xmg-neo-rgb-kbd-lights set-color red
```


## Power Monitoring


### ~/bin/acpi-powerstate

```bash
#!/usr/bin/bash
# Maintained in linux-init-files.org
. /usr/share/acpi-support/power-funcs
. /usr/share/acpi-support/policy-funcs
getState
echo "export POWERSTATE=${STATE}"  > "$HOME"/.acpi-powerstate
export POWERSTATE=$STATE
```


### NVIDIA

1.  ~/bin/nvidia-power-usage

    ```bash
    #!/usr/bin/bash
    # Maintained in linux-init-files.org
    for i in $(seq 1 ${1:-5})
    do
        sleep ${2:-1} && echo "$(date +"%Y-%m-%d %H:%M:%S"):$(nvidia-smi -q -d POWER | grep Draw | sed 's/  */ /g')"
    done

    ```


## Google Translate Helpers

```bash
sudo apt install translate-shell
```


### ~/bin/google-trans

```bash
#!/usr/bin/bash
#Maintained in linux-init-files.org
src=$1;shift;
dst=$1;shift;
txt=$@;
trans -e google -s ${src} -t ${dst} -show-original y -show-original-phonetics y -show-translation y -no-ansi -show-translation-phonetics n -show-prompt-message n -show-languages y -show-original-dictionary y -show-dictionary y -show-alternatives y "$txt"
```


### ~/bin/google-trans-de-en

```bash
#!/usr/bin/bash
#Maintained in linux-init-files.org
trans -e google -s de -t en -show-original y -show-original-phonetics y -show-translation y -no-ansi -show-translation-phonetics n -show-prompt-message n -show-languages y -show-original-dictionary y -show-dictionary y -show-alternatives y "$@"
```


### ~/bin/google-trans-en-de

```bash
#!/usr/bin/bash
#Maintained in linux-init-files.org
trans -e google -s en -t de -show-original y -show-original-phonetics y -show-translation y -no-ansi -show-translation-phonetics n -show-prompt-message n -show-languages y -show-original-dictionary y -show-dictionary y -show-alternatives y "$@"
```


## Security/Locking/GPG


### ~/bin/cache-gpg

```bash
#!/usr/bin/bash
#Maintained in linux-init-files.org
SERVICE="gpg-agent"
if pgrep -x "$SERVICE" >/dev/null
then
    echo "agent already running"
else
    p=$(zenity --password --title "Password for SSH")
    if [ ! -z "$p" ]
    then
        [ ! -z "$GPG_KEY1" ] && echo "$p" | /usr/lib/gnupg2/gpg-preset-passphrase --preset "$GPG_KEY1" &> /dev/null
        [ ! -z "$GPG_KEY2" ] && echo "$p" | /usr/lib/gnupg2/gpg-preset-passphrase --preset "$GPG_KEY2" &> /dev/null
    fi
fi

```

\#+end\_src


### ~/bin/pre-lock

```bash
#!/usr/bin/bash
#Maintained in linux-init-files.org
[ -f "${HOME}"/.pre-lock ]  && . "${HOME}"/.pre-lock
```

1.  Sample .pre-lock

    ```bash
    #!/usr/bin/bash
    xmg-neo-rgb-kbd-lights sleep
    ```


### ~/bin/post-lock

```bash
#!/usr/bin/bash
#Maintained in linux-init-files.org
[ -f "${HOME}"/.post-lock  ]  && . "${HOME}"/.post-lock
```

1.  Sample .post-lock

    ```bash
    #!/usr/bin/bash
    xmg-neo-rgb-kbd-lights wake
    ```


### ~/bin/pre-blank

```bash
#!/usr/bin/bash
#Maintained in linux-init-files.org
command -v brightnessctl && brightnessctl -s
[ -f ~/.pre-blank ]  && . ~/.pre-blank
```


### ~/bin/post-blank

```bash
#!/usr/bin/bash
#Maintained in linux-init-files.org
[ -f ~/.post-blank ]  && . ~/.post-blank
command -v brightnessctl && brightnessctl -r
```


# tailends


## ~/.bash\_profile

```bash
[ -f "${HOME}/.bash_profile.local" ] && . "${HOME}/.bash_profile.local"
# export USER_STARTX_NO_LOGOUT_ON_QUIT=""
[ -z "$DISPLAY" ] && [ $(tty) = /dev/tty1 ] && [ -f ~/.START_X ] && {
    echo "Auto starting via startx with USER_STARTX_NO_LOGOUT_ON_QUIT:${USER_STARTX_NO_LOGOUT_ON_QUIT}"
    [ -z "$USER_STARTX_NO_LOGOUT_ON_QUIT" ] && exec startx || startx
}
```


## Late addition to ~/.profile

```bash
[ -f "${HOME}/.profile.local" ] && . "${HOME}/.profile.local"
```
