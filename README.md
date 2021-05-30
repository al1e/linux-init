# Introduction


## Status

Work in progress!! Keep all config and scripts in a single org file for documentation. Use org tangling for exporting them.


## GIT


### gitconfig-mode

```emacs-lisp
(use-package gitconfig-mode)
```


### ~/.gitconfig

global git settings NB - NOT Exported as lots of things want to update it

```gitconfig
[user]
        name = rileyrg
        email = rileyrg@gmx.de
[push]
        default = current
[github]
        user = rileyrg
[pull]
        rebase = false
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


# X Related     :ARCHIVE:


# User system services


### gpg-agent

If using startx on debian this is taken care of by the system XSession loading everyhing in /etc/X11/Xsession.d. see [/usr/share/doc/gnupg/examples](file:///usr/share/doc/gnupg/examples)


# Bash Startup Files


# Auto login for tty

,-&#x2014;

| <https://unix.stackexchange.com/a/401798/228272>                              |
| Edit your /etc/systemd/logind.conf , change #NAutoVTs=6 to NAutoVTs=1         |
| Create a /etc/systemd/system/getty@tty1.service.d/override.conf through ;     |
| systemctl edit getty@tty1                                                     |
| Paste the following lines                                                     |
| [Service]                                                                     |
| ExecStart=                                                                    |
| ExecStart=-/sbin/agetty &#x2013;autologin root &#x2013;noclear %I 38400 linux |
| enable the getty@tty1.service then reboot                                     |
| systemctl enable getty@tty1.service                                           |
| reboot                                                                        |

\`-&#x2014;

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


## ~/.profile

```bash
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


```


## ~/.bash\_profile

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
logger -t "startup-initfile"  BASH_PROFILE

[ -f ~/.profile ] && . ~/.profile || true
[ -f ~/.bashrc ] && . ~/.bashrc || true

## this bit sucks. start mbsync,time manually if enrypted homedir else it doesnt work
systemctl is-active --user mbsync.timer || systemctl --user start mbsync.timer

```


## ~/.bashrc

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
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
# Maintained in linux-config.org
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

ZSH_THEME=robbyrussell

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
    chucknorris
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
chuck
```


## ~/.config/zsh/.zlogin

```bash
# Maintained in linux-config.org
logger -t "startup-initfile"  ZLOGIN
# [ -s "$HOME/.rvm/scripts/rvm" ] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
```


## zprofile

1.  ~/.config/zsh/.zprofile

    ```bash
    # Maintained in linux-config.org
    logger -t "startup-initfile"  ZPROFILE
    if [ -f ~/.profile ]; then
        emulate sh -c '. ~/.profile'
    fi
    ```

2.  etc/zsh/zprofile

    ```bash
    # Maintained in linux-config.org
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
    # Maintained in linux-config.org
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
    # Maintained in linux-config.org
    logger -t "startup-initfile"  ZSHENV
    if [ -z "$XDG_CONFIG_HOME" ] && [ -d "$HOME/.config" ]
    then
        export XDG_CONFIG_HOME="$HOME/.config"
    fi

    if [ -d "$XDG_CONFIG_HOME/zsh" ]
    then
        export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
    fi
    xhost +SI:localuser:root
    ```


## Oh-My-Zsh Related

Directory is [here](.oh-my-zsh/).

1.  Aliases ~/.config/zsh/oh-my-zsh/custom/aliases.zsh

    ```conf
    # Maintained in linux-config.org
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
# Maintained in linux-config.org
logger -t "startup-initfile"  ADD_USER_PATHS
#export PATH="${HOME}/bin:$HOME/.local/bin:${HOME}/.cargo/bin:./node_modules/.bin:$PATH"
```


# Tmux     :tmux:


## ~/.profile

```bash
export FZF_TMUX_OPTS=1
export FZF_TMUX_OPTS="-d 40%"
```


## ~/.tmux.conf


### start

```conf
# Maintained in linux-config.org
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
set -g @plugin 'sainnhe/tmux-fzf'

run -b '~/.tmux/plugins/tpm/tpm'

```


## ~/bin/tmux-current-session

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
echo "$(tmux list-panes -t "$TMUX_PANE" -F '#S' | head -n1)"
```


## ~/bin/tmux-pane-tty

Written to find the tty for a pane in order to redirect gef context source to a voltron pane

```bash
#!/usr/bin/bash
#Maintained in linux-config.org
session="${1:-""}"
[ -z ${session} ] && exit 1
pane_index="${2:-0}"
window="${3:-0}"
tmux list-panes -t "${session}:${window}" -F 'pane_index:#{pane_index} #{pane_tty}' | awk '/pane_index:'"${pane_index}"'/ {print $2 }'
```


# zellij terminal


## config

```conf
simplified_ui: true
```


# Sway Wayland Compositing Tile Manager     :i3:swaywm:sway:

Sway is a tiling Wayland compositor and a drop-in replacement for the i3 window manager for X11. It works with your existing i3 configuration and supports most of i3's features, plus a few extras.


## xkb keyboard

Set keyboard layout. Override in .profile.local

```bash
export XKB_DEFAULT_LAYOUT=de
export XKB_DEFAULT_OPTIONS=ctrl:nocaps
```


## Gnome     :ARCHIVE:


## swaysock for tmux

```bash
export SWAYSOCK=/run/user/$(id -u)/sway-ipc.$(id -u).$(pgrep -x sway).sock
```


## ~/.Xresources


### resource file

X11 apps still need resource definitions when launched under XWayland.

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


## Building from source


### wayland

```bash
mkdir -p $HOME/development/projects/wayland/clones
export WLD=$HOME/development/projects/wayland
export LD_LIBRARY_PATH=$WLD/lib
export PKG_CONFIG_PATH=$WLD/lib/pkgconfig/:$WLD/share/pkgconfig/
export PATH=$WLD/bin:$PATH

cd $HOME/development/projects/wayland/clones

git clone https://gitlab.freedesktop.org/wayland/wayland.git
cd wayland
meson build/ --prefix=$WLD
ninja -C build/ install
cd ..

git clone https://gitlab.freedesktop.org/wayland/wayland-protocols.git
cd wayland-protocols
meson build/ --prefix=$WLD
ninja -C build/ install
cd ..

git clone https://gitlab.freedesktop.org/wayland/weston.git
cd weston
meson build/ --prefix=$WLD -Dbackend-wayland=true -Dcolor-management-colord=false -Dremoting=false
ninja -C build/ install
cd ..

```


### sway

```emacs-lisp
# Clone repositories

git clone git@github.com:swaywm/sway.git
cd sway
git clone git@github.com:swaywm/wlroots.git subprojects/wlroots

# Build sway and wlroots
meson build/
ninja -C build/

# Start sway
build/sway/sway
```


## notification daemon


### mako

Use mako as the notification daemon

1.  install

    ```bash
    sudo apt install mako-notifier
    ```

2.  ~/.config/mako/config

    ```conf
    anchor=top-right
    background-color=#da4f37
    ```

3.  notification daemon

    ```bash
    sudo apt install notification-daemon libnotifier-bin
    ```

    Enable it as a dbus service <https://wiki.archlinux.org/title/Desktop_notifications> $XDG\_DATA\_HOME/dbus-1/services/org.freedesktop.Notifications.service

    ```conf
    [D-BUS Service]
    Name=org.freedesktop.Notifications
    Exec=/usr/lib/notification-daemon/notification-daemon
    ```


## Sway config


### general

```conf
# Maintained in linux-config.org

set $mod Mod4
set $term 'oneterminal'
set $menu 'sway-launcher-fzf'
set $editor 'sway-editor'
set $wallpaper '~/Pictures/Wallpapers/current'

include /etc/sway/config-vars.d/*
include config-vars.d/*

# start a terminal
# Use Mouse+$mod to drag floating windows to their wanted position
floating_modifier $mod
# kill focused window
bindsym $mod+q kill
bindsym $mod+0 kill

# Font  for window titles. Will also be used by the bar unless a different font
# is used in the bar {} block below.
font pango:DejaVu Sans Mono, Terminus Bold Semi-Condensed 11

# reload the configuration file
bindsym $mod+Shift+c reload
# restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
Bindsym $mod+Shift+r restart

bindsym $mod+Shift+e exec $editor
bindsym $mod+d exec $menu

```


### xrdb integration

```conf
exec xrdb -merge ~/.Xresources
```


### launcher

```conf
for_window [title="sway-launcher"] floating enable
```


### display

1.  wallpaper

    ```conf
    set $wallpaper "~/Pictures/Wallpapers/current"
    output * bg  $wallpaper fill
    ```

2.  transparency

    ```conf
    set $trans 0.8
    set $alphamark "α"
    for_window [con_mark=$alphamark] opacity set $trans
    bindsym $mod+Control+a mark --toggle "$alphamark" ; [con_id=__focused__] opacity set 1 ; [con_mark=$alphamark con_id=__focused__] opacity set $trans
    ```

3.  lid     :lid:clamshell:

    ```conf
    set $laptop-id `sway-laptop-id`
    bindswitch lid:on exec "sway-screen disable $laptop-id"
    bindswitch lid:off exec "sway-screen enable $laptop-id"
    ```

4.  brightness     :brightness:

    ```conf
    bindsym --locked XF86MonBrightnessUp exec --no-startup-id light -A 10 && sway-brightness-notify
    bindsym --locked XF86MonBrightnessDown exec --no-startup-id light -U 10 && sway-brightness-notify
    ```

5.  gaps

    ```conf
    gaps inner  2
    gaps outer  2
    ```


### scratchpad terminal

I want a key to create and then toggle a terminal.

```conf

bindsym $mod+Shift+minus move scratchpad
bindsym $mod+minus scratchpad show
bindsym $mod+Return exec sway-scratch-terminal

for_window [title=ScratchTerminal] mark "$alphamark", move to scratchpad; [title=ScratchTerminal] scratchpad show
```

1.  ~/bin/sway/sway-scratch-terminal

    ```bash
    #!/usr/bin/bash
    #Maintained in linux-config.org
    swaymsg "[title=ScratchTerminal] scratchpad show " || ( sway-notify "created new scratchpad terminal" && alacritty --title "ScratchTerminal" --command bash -c "tmux new-session -A -s ScratchTerminal")
    ```


### navigation                                  :navigation

```conf
# change focus
# bindsym $mod+h focus left
# bindsym $mod+j focus down
# bindsym $mod+k focus up
# bindsym $mod+l focus right

bindsym $mod+o focus left

# alternatively, you can use the cursor keys:
bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right

# move focused window
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

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

# toggle tiling / floatving
bindsym $mod+Shift+space floating toggle

# change focus between tiling / floating windows
bindsym $mod+space focus mode_toggle

# focus the parent container
bindsym $mod+a focus parent

bindsym $mod+Shift+s sticky toggle

bindsym $mod+m move workspace to output left
bindsym $mod+Control+m exec sway-display-swap
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

workspace $ws3 gaps inner 2
workspace $ws3 gaps outer 2

assign [title="dbg:"] $ws3

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
#  bindsym $mod+0 workspace number $ws10

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


### clipboard

```conf
exec wl-paste -t text --watch clipman store --max-items=60 --histpath="~/.config/clipman/clipman.json"
bindsym $mod+y exec clipman pick --tool="wofi" --max-items=30 --
```


### audio     :audio:

1.  volume     :volume:

    ```conf
    bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5% && sway-volume-notify
    bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5% && sway-volume-notify
    bindsym XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle && sway-volume-notify
    bindsym XF86AudioMicMute exec pactl set-source-mute @DEFAULT_SOURCE@ toggle && sway-volume-notify
    ```

2.  pavucontrol

    ```conf
    for_window [app_id="pavucontrol"] floating enable
    bindsym $mod+Control+Shift+a exec pulse-restart
    ```


### wifi     :wifi:

```conf
bindsym --locked XF86Wlan exec sleep 1 && sway-notify "WLAN is $(nmcli radio wifi)."
```


### exit, quit, restart, reboot, lock, hibernate, blank, suspend     :hibernate:lock:sleep:blank:blank:restart:exit:reboot:

```conf

bindsym  $mod+Control+l exec sway-lock-utils lock

set $mode_system System (b) blank (l) lock, (e) logout, (s) suspend, (h) hibernate, (r) reboot, (Shift+s) shutdown
mode "$mode_system" {
bindsym b exec sway-lock-utils blank, mode "default"
bindsym l exec sway-lock-utils lock, mode "default"
bindsym e exec sway-lock-utils logout, mode "default"
bindsym s exec sway-lock-utils suspend, mode "default"
bindsym h exec sway-lock-utils hibernate, mode "default"
bindsym r exec sway-lock-utils reboot, mode "default"
bindsym Shift+s exec sway-lock-utils shutdown, mode "default"
# back to normal: Enter or Escape
bindsym Return mode "default"
bindsym Escape mode "default"
}
bindsym $mod+Control+q mode "$mode_system"
```


### apps default workspace

```conf
assign [class="Signal"] $ws8
assign [class="Hexchat"] $ws8
assign [class="discord"] $ws8
assign [class="Steam"] $ws9
```


### apps default appearance

```conf
for_window [class="feh"] floating enable
for_window [class="Conky"] floating enable
for_window [app_id="zenity"] floating enable
for_window [title="wifi"] floating enable
for_window [title="bluetoothctl"] floating enable
```


### apps keybindings

```conf

bindsym $mod+g exec "goldendict \\"`xclip -o -selection clipboard`\\""
bindsym Print exec sway-screenshot -i
bindsym $mod+Shift+f exec sway-do-tool "Google-chrome" "sway-www"
bindsym $mod+Control+Shift+f exec  "sway-www"
bindsym $mod+Control+b exec oneterminal "Process-Monitor-bpytop" bpytop
bindsym $mod+Control+c exec conky
bindsym $mod+Control+s exec sway-do-tool "Signal" "signal-desktop"
bindsym $mod+Control+Shift+s exec sway-do-tool "Steam" "steam"
bindsym $mod+Control+h exec sway-do-tool "Hexchat" "hexchat"
bindsym $mod+Control+d exec emacsclient -c -eval '(dired "~")'
bindsym $mod+Control+Shift+d exec sway-screen-menu
bindsym $mod+Control+f exec command -v thunar && thumar || nautilus
bindsym $mod+Control+e exec gdb-run ~/development/projects/emacs/emacs/src
bindsym $mod+Control+g exec oneterminal "gdb"
bindsym $mod+Control+v exec ONETERM_TITLE="dbg:voltron" oneterminal $(voltron-session)
bindsym $mod+Control+o exec xmg-neo-rgb-kbd-lights toggle && x-backlight-persist restore
bindsym $mod+Control+p exec sway-htop
bindsym $mod+Control+Shift+p exec htop-regexp
bindsym $mod+Control+t exec sway-notify "Opening NEW terminal instance" && alacritty -e zsh
```


### gaming     :gaming:

1.  steam     :steam:

    ```conf
    for_window [class="steam_app.*"] fullscreen enable
    for_window [class="steam_app*"] inhibit_idle focus
    ```


### status bar

1.  waybar     :waybar:

    <https://github.com/Alexays/Waybar/wiki/Configuration>

    ```conf
    bar {
    swaybar_command waybar
    }
    bindsym $mod+Alt+b exec killall -SIGUSR1 waybar

    ```

    1.  ~/.config/waybar/config

        ```json
        {
          "layer": "top",
          "position": "bottom",
          "height": 30,
          "width": 1280,

          "modules-left": [
            "sway/workspaces",
            "sway/mode",
            "cpu",
            "temperature",
            "memory",
            "custom/uptime",
            "custom/dropbox"
          ],

          "modules-center": [
            "custom/clock",
            "custom/weather",
            "idle_inhibitor",
            "custom/monitors",
          ],

          "modules-right": [
            "pulseaudio",
            "custom/bluetooth",
            "backlight",
            "battery",
            "custom/power-draw",
            "network",
            "wlr/taskbar",
          ],

          "network": {
            "format-wifi": "<span color='#589df6'></span> <span color='gray'>{signalStrength}%</span>" ,
            "format-ethernet": "{ifname}: {ipaddr}/{cidr} ",
            "format-linked": "{ifname} (No IP) ",
            "format-disconnected": " ",
            "format-alt": "<span color='gray'>{essid}</span> <span color='green'>⬇</span>{bandwidthDownBits} <span color='green'>⬆</span>{bandwidthUpBits}",
            "interval": 60,
            "tooltip-format": "{ifname}  {ipaddr}",
          },


          "sway/workspaces": {
            "disable-scroll": true,
            "all-outputs": true,
            "format": "{name}",
            "format-icons": {
              "urgent": "<span color='#e85c5c'></span>",
              "focused": "<span color='#8af0f0'></span>",
              "default": "<span color='#b8b8b8'></span>"
            }
          },

          "sway/mode": {
            "format": "{}"
          },

          "backlight": {
            //		"device": "acpi_video1",
            "format": "{icon} {percent}%",
            "format-icons": ["🔅", "🔆"]
          },

          "battery": {
            "states": {
              // "good": 95,
              "warning": 20,
              "critical": 10
            },
            "format": "<span color='gold'>{icon}</span> {capacity}%",

            "format-charging": "<span color='gold'> </span> {capacity}% ({time})",
            "format-plugged":  "<span color='gold'>{icon}  </span> {capacity}%",
            //		"format-good": "", // An empty format will hide the module
            "format-discharging": "<span color='yellow'>{icon}</span> {capacity}% ({time})",
            "format-icons": ["", "", "", "", ""],
            "on-click" : "sway-htop",
          },

          "custom/clock": {
            "interval": 60,
            "exec": "date +'%a, %d %b: %H:%M'",
            "format": "{} ",
            "max-length": 25,
          },

          "cpu": {
            "interval": 5,
            "format": "<span color='#eb8a60'> {usage}% ({load})</span>", // Icon: microchip
            "states": {
              "warning": 70,
              "critical": 90
            },
            "on-click" : "hardinfo",
          },

          "idle_inhibitor": {
            "format": "<span color='GOLD'>{icon}</span>",
            "format-icons": {
              "activated": "📀🎞",
              "deactivated": "😴🛌"
            },
            "on-click-right": "sway-lock"
          },
          "pulseaudio": {
            //		"scroll-step": 1, // %, can be a float
            "format": "{icon} {volume}% {format_source}",
            "format-muted": "🔇 {format_source}",
            "format-bluetooth": "{icon} {volume}% {format_source}",
            "format-bluetooth-muted": "🔇 {format_source}",

            "format-source": " {volume}%",
            "format-source-muted": "",

            "format-icons": {
              "headphones": "",
              "handsfree": "",
              "headset": "",
              "phone": "",
              "portable": "",
              "car": "",
              "default": ["🔈", "🔉", "🔊"]
            },
            "on-click": "amixer set Master toggle",
            "on-click-right": "pavucontrol"
          },
          /*
            "temperature": {
            //		"thermal-zone": 2,
            //		"hwmon-path": "/sys/class/hwmon/hwmon2/temp1_input",
            "critical-threshold": 80,
            //		"format-critical": "{temperatureC}°C {icon}",
            "format": "<span color='#e88939'>{icon}</span> {temperatureC}°C",
            "format-icons": ["", "", ""],
            "tooltip": false
            },
          */
          "tray": {
            "icon-size": 18,
            "spacing": 5
          },


          "custom/weather": {
            "format": "<span color='gray'>{}</span>",
            "interval": 18000,
            "exec": "waybar-weather",
            "exec-if": "waybar-weather -q",
            "tooltip": "false",
            "on-click": "sway-weather",
          },

          "custom/uptime": {
            "format": "<span color='white'>⌛{}</span>",
            "interval": 60,
            "exec": "uptime -p",
          },
          "custom/dropbox": {
            "format": "<span color='gold'>⇄ {}</span>",
            "interval": 5,
            "exec": "waybar-dropbox-status",
            "tooltip": "false",
            "on-click": "sway-www https://www.dropbox.com/h",
          },
          "custom/monitors": {
            "format": "<span color='gold'>{}</span>",
            "return-type" : "json",
            "interval": 10,
            "exec": "waybar-monitors",
            "tooltip": "true",
            "on-click": "sway-screen-menu",
          },
          "custom/bluetooth": {
            "format": "<span color='blue'>{}</span>",
            "interval": 30,
            "exec": "waybar-bluetooth",
            "tooltip": "false",
            "on-click": "sway-bluetooth",
          },
          "custom/power-draw": {
            "format": "<span color='gold'>⚡{}🔋</span>",
            "interval": 5,
            "exec": "waybar-power-draw",
            "tooltip": "false",
          },

          "wlr/taskbar": {
            "format": "{icon}",
            "icon-size": 14,
            "icon-theme": "Numix-Circle",
            "tooltip-format": "{title}",
            "on-click": "activate",
            "on-click-middle": "close",
          },

          "custom/mynetwork": {
            "format":  "{}",
            "format-wifi":  "📶{ssid}",
            "format-ipaddr": "{ipaddr}",
            "format-ssid": "xx{ssid}xx",
            "format-alt": "{alt}:{}",
            "exec": "waybar-ip-info-json",
            "return-type": "json",
            "interval": 60,
            "on-click-right": "sway-wifi",
            "tooltip-format": "{ssid}",
            "tooltip": "true",
          },

        }
        ```

    2.  ~/.config/waybar/style.css

        ```css
        * {
            border: none;
            background: rgba(28, 28, 28, 0.6);
            border-radius: 0;
            font-family: "monospace";
            font-size: 10pt;
            min-height: 0;
        }

        #waybar {
            background: rgba(28, 28, 28, 0.6);
            color: #e4e4e4;
        }

        #window {
            color: #e4e4e4;
            font-weight: bold;
        }

        #workspaces {
            font-size: 8px;
            /*	padding: 0 2px;*/
            margin-left: 8px;
            margin-right: 8px;
            padding-left: 0px;
            padding-right: 0px;
            border-top-left-radius: 10px;
            border-bottom-left-radius: 10px;
            border-top-right-radius: 10px;
            border-bottom-right-radius: 10px;
            background: rgba(28, 28, 28, 0.6);
        }

        #workspaces button {
            padding: 0 5px;
            /*	background: rgba(28, 28, 28, 0.9);*/
            color: #b8b8b8;
            /*	margin: 0 1px;*/
        }
        #workspaces button:hover {
            box-shadow: inherit;
            text-shadow: inherit;

        }

        #workspaces button.focused {
            padding: 0 5px;
            border-radius: 10px;
            /*	background: #00afd7;*/
            color: #8af0f0;
            margin: 0 0px;
        }

        #workspaces button.urgent {
            background: #af005f;
            color: #1b1d1e;
        }

        #mode {
            background: #af005f;
        }

        #custom-bluetooth,#custom-power-draw,#custom-dropbox,#clock, #temperature, #cpu, #memory, #network, #backlight, #pulseaudio, #battery, #tray, #idle_inhibitor {
            padding: 0 3px;
        }

        #idle_inhibitor{
            font-size:16px
        }

        #clock {
            border-top-left-radius: 10px;
            border-bottom-left-radius: 10px;
        }

        @keyframes blink {
            to {
                background-color: darkred;
            }
        }

        #battery.warning:not(.charging) {
            background-color: #ff8700;
            color: #1b1d1e;
        }
        #battery.critical:not(.charging) {
            color: white;
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }
        #battery,#battery_icon,#battery.charging {
            color:gold
        }


        #cpu {
        }

        #memory {
        }

        #network {
        }

        #network.disconnected {
            background: #f53c3c;
        }

        #pulseaudio {
        }

        #pulseaudio.muted {
        }

        #custom-weather {
            font-size:12px;
        }

        #tray {
            margin-left: 1px;
        }
        ```

    3.  scripts

        1.  ~/bin/sway/waybar-bluetooth

            Thank you <https://github.com/deanproxy/dotfiles/blob/master/linux/i3/scripts/bluetooth>

            ```bash
            #!/usr/bin/env bash
            # Maintained in linux-config.org

            get_from_file() {
                dev=$1
                name=
                if [ ! -f /tmp/bt-devices.txt ]; then
                    touch /tmp/bt-devices.txt
                    echo ""
                    return
                fi
                for i in `cat /tmp/bt-devices.txt`; do
                    d=`echo $i | awk -F:: '{print $1}'`
                    if [ $d = $dev ]; then
                        name=`echo $i | awk -F:: '{print $2}'`
                    fi
                done
                echo "${name}"
            }

            store_file() {
                dev=$1
                name="${2}"
                echo "$dev::${name}" >> /tmp/bt-devices.txt
            }

            connections=`hcitool con | sed -n 2p`
            if [ ! -z "$connections" ]; then
                # We have a connection, we want to get the name from a file if we've had
                # it from there before because getting the name of the device connected
                # is very slow and costly.
                dev=`echo $connections | awk '{print $3}'`
                name=`get_from_file $dev`
                if [ -z "$name" ]; then
                    name=`hcitool name $dev | awk '{print $1}'`
                    if [ ! -z "${name}" ]; then
                        store_file $dev "${name}"
                    fi
                fi
                echo "💡$name"
            else
                echo "🔌"
            fi
            ```

        2.  ~/bin/sway/waybar-power-draw

            ```bash
            #!/usr/bin/env bash
            # Maintained in linux-config.org
            awk '{print $1*10^-6 " W"}' /sys/class/power_supply/BAT0/power_now
            ```

        3.  ~/bin/sway/waybar-ip-info-json

            ```bash
            ifname="${1:-$(printf '%s' /sys/class/net/*/wireless | cut -d/ -f5)}"
            [ -z "$ifname" ] && exit 1
            pubip="$(curl -s -m 1 ipinfo.io/ip)"
            pubip="$([ -z "$pubip" ] && echo "Offline" || echo "$pubip")"
            lip=$(ip -j address | jq -r '.[] | select (.ifname=='\"$ifname\"').addr_info[] | select(.family=="inet").local')
            lip="$([ -z "$lip" ] && echo -n "Offline" || echo -n "$lip")"
            ssid="$(/sbin/iwconfig $ifname | grep 'ESSID:' | awk '{print $4}' | sed 's/ESSID://g' | sed 's/"//g')"
            jq --unbuffered --compact-output -n \
                              --arg text "📶 $ssid" \
                              --arg alt "$ifname:🌎$pubip,🔌$lip" \
                              --arg tooltip "$ifname:🌎$pubip,🔌$lip" \
                              --arg class "" \
                              --arg percentage "1" \
                              --arg ifname "$ifname" \
                              --arg ssid "$ssid" \
                              --arg public_ip "$pubip" \
                              --arg ippadr "$lip" \
                              '{text: $text, alt: $alt, tooltip: $tooltip, class: $class, percentage: $percentage, ifname: $ifname, ssid: $ssid, public_ip: $public_ip, ipaddr: $ippadr}'
            ```

        4.  ~/bin/sway/waybar-monitors

            ```bash
            #!/usr/bin/bash
            #Maintained in linux-config.org
            l=$(swaymsg -t get_outputs | jq  -r '[ .[] | select(.dpms and .active) ] | length')
            o=$(swaymsg -t get_outputs | jq  -r '. | map(.name) | join(",")')
            t=""
            for i in `seq $l`; do t="${t}🖥️";done
            text="{\"text\":\""$t"\",\"tooltip\":\""$o"\"}"
            echo $text
            ```

        5.  ~/bin/sway/waybar-weather

            ```bash
            #!/usr/bin/env bash
            # Maintained in linux-config.org
            if [  "$1" = "-q" ]; then
                ping openweathermap.org -c1
            else
                export OPENWEATHERKEY="${OPENWEATHERKEY:-$(head -n 1 $HOME/.config/openweathermap/freemium)}"
                ansiweather -l "${OPENWEATHER_LOCATION:-"Grömitz,DE"}" -k"$OPENWEATHERKEY" -f 0 -u metric -s true -w true -p true -h false -a false | cut -d ' '  -f6-
            fi
            ```

        6.  ~/bin/sway/waybar-dropbox-status

            ```bash
            #!/usr/bin/bash
            #Maintained in linux-config.org
            if pidof dropbox &> /dev/null ; then
                stat=$(dropbox status | sed -n 1p)
                echo "${stat}"; echo "";
            else
                if command -v dropbox > /dev/null; then
                    echo "⇄Restarting Dropbox.."
                    dropbox start &> /dev/null &
                fi
            fi
            ```


### autostart     :autostart:

```conf
exec sway-lock
exec dropbox-start-once
exec sway-kanshi
exec sway-idle
exec '[ -f "$HOME/.sway-autostart" ]  && . "$HOME/.sway-autostart" && (sleep 1 && sway-notify "~/.sway-autostart processed")'
exec sleep 2 && gpg-cache
exec swaymsg workspace $ws1
```


### library include

```conf
include /etc/sway/config.d/*
```


## bin,scripts     :sway:wayland:


### ~/bin/sway-sway-active-monitors-count

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
swaymsg -t get_outputs | jq  -r '[ .[] | select(.dpms and .active) ] | length'
```


### ~/bin/sway/sway-autostart

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
[ -f "$HOME/.sway-autostart" ]  && . "$HOME/.sway-autostart"
```


### ~/bin/sway/sway-brightness-notify

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
sway-notify "🔆:$(printf "%.0f" `light -G`)"
```


### ~/bin/sway/sway-bluetooth

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
exec oneterminal "bluetoothctl" "bluetoothctl"
```


### ~/bin/sway/sway-do-tool

```bash
#!/usr/bin/bash
# Maintained in linux-config.org

# NB ths is currently lazy. It uses brute force, and i need to do some get_tree jq stuff instead to
# get the app_id/class instance instead. But.. it works.

id="$1"
script="$2"
[ -z "$id" ] && echo "usage: sway-do-tool id" && exit 1
if swaymsg "[title=${id}] focus" &> /dev/null; then
    rgr-logger -t "sway-do-tool" "title ${id} found"
else
    if  swaymsg "[class=^${id}] focus" &> /dev/null; then
        rgr-logger -t "sway-do-tool" "class ${id} found"
    else
        if  swaymsg "[app_id=^${id}] focus" &> /dev/null; then
            rgr-logger -t "sway-do-tool" "app_id ${id} found"
        else
            if [ ! -z "$script" ]; then
                rgr-logger -t "sway-do-tool" "evaling script $scipt"
                eval "$script" &
            else
                rgr-logger -t "sway-do-tool" "exiting"
                exit 1
            fi
        fi
    fi
fi
exit 0
```


### ~/bin/sway/sway-dpms

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
DPMS="${1:-on}"
DISP="${2:-*}"
currentDPMS="$(swaymsg -t get_outputs | jq -r '.[0]'.dpms)"
[ "$dpms" != "$currentDPMS" ] && swaymsg "output $DISP DPMS $DPMS"
```


### ~/bin/sway/sway-editor

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
exec emacs-same-frame "$@"
```


### ~/bin/sway/sway-htop

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
exec oneterminal "Processes" htop
```


### ~/bin/sway/sway-kanshi

Monitor control with hotplug <https://github.com/emersion/kanshi> Load a host specific kanshi file if it exists

```bash
#!/usr/bin/bash
#Maintained in linux-config.org
# pidof kanshi && echo "kanshi process $(pidof kanshi) already running. Exiting." && exit 0
killall -9 kanshi &>/dev/null
config="$HOME/.config/kanshi/config-$(hostname)"
if [ -f  "$config" ]; then
    rgr-logger -t "kanshi"  "$config"
    exec kanshi -c "$config"
else
    rgr-logger -t "kanshi"  "default config"
    exec kanshi
fi
```

1.  config

    ```conf
    {
    output eDP-1 enable position 0,0
    }
    ```

2.  config-thinkpadt14s

    ```conf
    {
    output eDP-1 enable mode 1920x1080  position 0,0
    }

    {
    output eDP-1 mode 1920x1080 position 1920,0
    output DP-4 mode 1920x1080 position 0,0
    }
    ```

3.  config-thinkpadt460

    ```conf
    {
    output eDP-1 enable mode 1366×768   position 0,0
    }

    {
    output eDP-1 mode 1366×768  position 1920,0
    output DP-4 mode 1920x1080 position 0,0
    }
    ```

4.  config-thinkpadx270

    ```conf
    {
    output eDP-1 enable mode 1920x1080  position 0,0
    }

    {
    output DP-4 mode 1920x1080 position 0,0
    output eDP-1 disable
    }

    ```

    ******\*******


### ~/bin/sway/sway-lock-utils

Just a gathering place of locky/suspendy type things&#x2026;

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
lock() {
    pidof swaylock || swaylock -f -i ~/Pictures/LockScreen/current -s fill -c 000000 &
}

lock_gpg_clear() {
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
        swaymsg exit
        ;;
    suspend)
        systemctl suspend && lock
        ;;
    hibernate)
        systemctl hibernate && lock
        ;;
    reboot)
        systemctl reboot
        ;;
    shutdown)
        systemctl poweroff
        ;;
    blank)
        sway-dpms off
        ;;
    unblank)
        sway-dpms on
        ;;
    *)
        lock
        ;;
esac

exit 0
```


### ~/bin/sway/sway-idle     :sleep:lock:idle:

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
pidof swayidle  && killall -9 swayidle
exec swayidle -w \
     timeout 1 '' \
     resume 'sway-lock-utils unblank' \
     timeout 10 'pidof swaylock && sway-lock-utils blank' \
     resume 'sway-lock-utils unblank' \
     timeout ${XIDLEHOOK_BLANK:-300} 'sway-lock-utils blank' \
     resume 'sway-lock-utils unblank' \
     timeout ${XIDLEHOOK_LOCK:-900} 'sway-lock' \
     resume 'sway-lock-utils unblank' \
     timeout ${XIDLEHOOK_SUSPEND:-7200} 'sway-lock-utils suspend' \
     resume 'sway-lock-utils unblank' \
     lock 'sway-lock' \
     before-sleep 'sway-lock'
```


### ~/bin/sway/sway-laptop-id

Here we look for an env `LAPTOP_ID`. In my setup that would be set in `$HOME/.profile.local`. If thats not set we assume `eDP-1` but in both cases we check if it exists in the sway tree, and, if not, set it it to the first one found.

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
id="${LAPTOP_ID:-"eDP-1"}"
displays="$(swaymsg -t get_outputs | jq -r '.[0]')"
if [ -z  "$(jq '.|select(.name=="$id") | .name' <<< $displays)" ];then
    id="$(jq -r '[.][0].name' <<< $displays)"
fi
echo $id
```


### ~/bin/sway/sway-lock

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
sway-lock-utils lock
```


### ~/bin/sway/sway-notify

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
notify-send -t 3000 "${@}"
```


<a id="orge9eaa0d"></a>

### ~/bin/sway/sway-screen

`enable` or `disable`. Won't allow you to turn off the sole enabled display.

:ID: 82455cae-1c48-48b2-a8b3-cb5d44eeaee9

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
m="${2:-$(swaymsg -t get_outputs | jq -r '.[0].name')}"
c="${1:-enable}"
[ "$c" = "disable" ] && [ "$(sway-active-monitors-count)" = "1" ] && sway-notify "Not turning off single display $m" && exit 1
swaymsg "output ${m} ${c}"
(sleep 2 && sway-notify "${m}:${c}") &
```


### ~/bin/sway/sway-screen-menu

Gui to select a display and enable/disable it. Calls down to [~/bin/sway/sway-screen](#orge9eaa0d).

:ID: 82455cae-1c48-48b2-a8b3-cb5d44eeaee9

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
m=$(swaymsg -t get_outputs | jq -r '.[] |  "\(.name)\n\(.active)"'  | zenity  --title "Select Display" --list  --text "" --column "Monitor" --column "Enabled")
if [ ! -z "$m" ]; then
    c="$(zenity  --list  --title "Enable ${m}?" --text "" --radiolist  --column "Pick" --column "Enabled" TRUE enable FALSE disable)"
    if [ ! -z "$c" ]; then
        sway-screen $c $m
    fi
fi
exit 0
```


### ~/bin/sway/sway-swaysock     :swaysock:

```bash
#!/usr/bin/bash
#Maintained in linux-config.org
export SWAYSOCK=/run/user/$(id -u)/sway-ipc.$(id -u).$(pgrep -x sway).sock
```


### ~/bin/sway/sway-display-swap

<https://i3wm.org/docs/user-contributed/swapping-workspaces.html>

```bash
#!/usr/bin/bash
# Maintained in linux-config.org

DISPLAY_CONFIG=($(sway-msg -t get_outputs | jq -r '.[]|"\(.name):\(.current_workspace)"'))

for ROW in "${DISPLAY_CONFIG[@]}"
do
    IFS=':'
    read -ra CONFIG <<< "${ROW}"
    if [ "${CONFIG[0]}" != "null" ] && [ "${CONFIG[1]}" != "null" ]; then
        echo "moving ${CONFIG[1]} right..."
        sway-msg -- workspace --no-auto-back-and-forth "${CONFIG[1]}"
        sway-msg -- move workspace to output right
    fi
done
```


### ~/bin/sway/sway-launcher-wofi

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
exec dmenu_path | wofi --show drun,dmenu -i | xargs swaymsg exec --
```


### ~/bin/sway/sway-launcher-fzf

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
exec alacritty --title "sway-launcher" -e bash -c "dmenu_path | fzf | xargs swaymsg exec"
```


### ~/bin/sway/sway-screenshot

Thanks: <https://www.reddit.com/r/linuxmasterrace/comments/k1bjkp/i_wrote_a_trivial_wrapper_for_taking_screenshots/>

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
# thanks to: https://www.reddit.com/r/linuxmasterrace/comments/k1bjkp/i_wrote_a_trivial_wrapper_for_taking_screenshots/

DIR=${HOME}/tmp/Screenshots

mkdir -p "${DIR}"

FILENAME="screenshot-$(date +%F-%T).png"
region="$(slurp)"
if [ ! -z "$region" ]; then
    sway-notify "Taking pic in 5s.."
    sleep 5
    grim -g "$region" "${DIR}"/"${FILENAME}" || exit 1
    #Create a link, so don't have to search for the newest
    ln -sf "${DIR}"/"${FILENAME}" "${DIR}"/screenshot-latest.png
    sway-notify "Done! see ${DIR}/screenshot-latest.png"
fi
```


### ~/bin/sway/sway-volume-notify

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
muted=$(pacmd list-sinks | awk '/muted/ { print $2 }')
volume=$(awk -F"[][]" '/Left:/ { print $2 }' <(amixer sget Master))
exec sway-notify "🔊$([ $muted == "yes" ] && echo "Muted" || echo $volume)" &> /dev/null
```


### ~/bin/sway/sway-weather

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
sway-www "https://www.accuweather.com/en/de/gr%C3%B6mitz/23743/hourly-weather-forecast/176248"
```


### ~/bin/sway/sway-www

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
#google-chrome --use-gl=egl --enable-features=UseOzonePlatform --ozone-platform=wayland "$@" &> /dev/null &
google-chrome  "$@" &> /dev/null &
sleep 0.5 && sway-do-tool "Google-chrome"
```


### ~/bin/sway/sway-wifi

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
oneterminal "wifi" "nmtui"  &>/dev/null
```


# Vim


## ~/.vimrc

```conf
" Maintained in linux-config.org
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
# Maintained in linux-config.org
*~
.git
cache
.cache
```


## ~/.ripgreprc

```conf

# Maintained in linux-config.org
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

```conf
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
    # Maintained in linux-config.org

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
        # Maintained in linux-config.org
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
        # Maintained in linux-config.org
        directory="${1:-`pwd`}"
        session="${2}"
        ONETERM_TITLE="dbg:gdb"  oneterminal "$(gdb-session "${directory}" "${session}")" &
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
        # Maintained in linux-config.org
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
    # Maintained in linux-config.org
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
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    ```


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
        # Maintained in linux-config.org
        context=5
        ```


# PGP/GNUPG/GPG


## ~/.gnupg/gpg.conf

```conf
# Maintained in linux-config.org
use-agent
```


## ~/.gnupg/gpg-agent.conf

```conf
# Maintained in linux-config.org
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


## ~/.profile.local     :crypt:

&#x2013;&#x2014;BEGIN PGP MESSAGE&#x2013;&#x2014;

hQEMA7IjL5SkHG4iAQgAnAMLgodgtOc1tsGz6mRqJbkJsM+R+5MTPdsOdml6xMoL xFZjkYTDUGa3G6PsQHpbJ/tjD+6B4qmZIymq1EReWPtrepGGN6DNG8hLPVNnQ+9N WAFaK1o+gzzfsw9XuptT5Um47k2G3zm019mGKDe0OwYJJ/r/DTHpz9yI9nj5lVdq sdk0Y/WQL/5mcraC7LPz0FhIhuXqKKFNvcQCA6D0fTWJxlzqvXRzuc44LN+mvozq 9Q4WbvXp/etZjeiUYjXmz70KEYxFIch3OR4EGmV41apfojLTmR9R2dp/u3jYexMy NlXugS5egyP+ioiuuTcCsSjN4rxnDwSW868lLkdhIdLAPgFdxEWpJjtaJO0A9aIB 6lJTRLKPzuwTyGiyRdKO8yqYFYwllgfEr/87qcB/ajjRpkhw9tlD8zTrODt4ZUu2 MQQHK2rzvplmgDf2LvDMiM2gv7z4bI3YzOTiGu6m+SxW/j8LA71WRMwhFmUObgOb g44XzdKHAV0o0Q/ZPPnJU4dlKc9nRkNS3MzpORmUGAT1/FSwt+q7uzpuBTZ1crGl P/fo8sDBBu2QBoL2+gQZ11l7uSZMjTCR/8msBO5LbLDmyOUposbv6va1dzPN898F ZsaqN9VNjV2b75kQiPJsZaoekClV7yOFc10/VRKBFD1MlspEovrIpReI9by6azIU =nb0T &#x2013;&#x2014;END PGP MESSAGE&#x2013;&#x2014;


# ACPI


## power status


### acpid events

You must copy these into [*etc/acpi/events*](file:///etc/acpi/events/) if you have an encrypted home directory else symlink.

1.  /etc/acpi/events/user-powerstate

    ```conf
    # Maintained in linux-config.org
    # /etc/acpi/events/user-powerstate
    # Called when the user connects ac power to us
    #
    event=ac_adapter.*
    action=/etc/acpi/actions/user-powerstate.sh
    ```

2.  /etc/acpi/events/xmg-neo-powerstate

    ```conf
    # Maintained in linux-config.org
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
    # Maintained in linux-config.org
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
    # Maintained in linux-config.org
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
# Maintained in linux-config.org
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
# Maintained in linux-config.org
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
#Maintained in linux-config.org
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
#Maintained in linux-config.org

sessionname="${1:-`pwd`}"
title="${ONETERM_TITLE:-${sessionname}}"
script="${2}"
tflags="${3}"

if ! sway-do-tool "$title"; then
    rgr-logger -t "oneterminal" "Didn't find a terminal $title so starting a terminal"
    if tmux has-session -t "${sessionname}" &> /dev/null; then
        rgr-logger -t "oneterminal" "and attaching a session ${sessionname}"
    else
        rgr-logger -t "oneterminal" "creating ${sessionname} with script ${script}."
    fi
    alacritty --title "${title}" --command bash -c "tmux new-session -A -s ${sessionname} ${script}" &
else
    rgr-logger -t "oneterminal" "Found an existing terminal $title."
    if ! tmux has-session -t  "${sessionname}"; then
        rgr-logger -t "oneterminal" "It wasnt attached to session ${sessionname} so attaching it."
        tmux attach -t "${sessionname}"
    else
        rgr-logger -t "oneterminal" "It was already attached to session ${sessionname}"
    fi
fi
exit 0

```


### ~/bin/pop-window

```bash
#!/usr/bin/bash
#Maintained in linux-config.org
sway-do-tool "$@"
```


## network interface utilities

1.  ~/bin/my-iface-active-query

    ```bash
    #!/usr/bin/bash
    #Maintained in linux-config.org
    nmcli device show ${IFACE_ACTIVE:-$(my-iface-active)} | grep -i -m 1 "${1:-".*"}.*:" | awk '{print $2}'
    ```

2.  ~/bin/my-iface-active

    ```bash
    #!/usr/bin/bash
    #Maintained in linux-config.org
    IFACE_ACTIVE="$(nmcli device show | grep -m 1 "GENERAL.DEVICE" | awk '{print $2}')"
    export IFACE_ACTIVE
    echo $IFACE_ACTIVE
    ```

3.  ~/bin/my-iface-active-ssid

    ```bash
    #!/usr/bin/bash
    #Maintained in linux-config.org
    my-iface-active-query "GENERAL.CONNECTION"
    ```

4.  ~/bin/my-iface-active-ipaddr

    ```bash
    #!/usr/bin/bash
    #Maintained in linux-config.org
    my-iface-active-query "IP4.ADDRESS"
    ```

5.  ~/bin/my-iface-active-quality

    ```bash
    #!/usr/bin/bash
    #Maintained in linux-config.org
    my-iface-active-query "GENERAL.STATE"
    ```


## ~/bin/confirm-suspend

```bash
#!/usr/bin/bash
#Maintained in linux-config.org
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
# Maintained in linux-config.org
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
# Maintained in linux-config.org
${VISUAL:-${EDITOR:-vi}} "${@}"
```


## ~/bin/eman

Use emacs for manpages if it's running might be an idea set an alias such as 'alias man=eman'

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
mp="${1:-man}"
if pidof emacs; then
    emacsclient -c -e "(manual-entry \"-a ${mp}\")" &> /dev/null &
else
    oneterminal random-man "man $mp"
fi
```


## ~/bin/expert-advice

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
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
# Maintained in linux-config.org
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
#Maintained in linux-config.org
filter="${1:-"$(zenity --entry --text "HTop filter" --title "htop regexp")"}"
[ -z "$filter" ] && exit 1
session="${2:-"htop-filter-${filter//[^[:alnum:]]/}"}"
pids=$(ps aux | awk '/'"${filter}"'/ {print $2}' | xargs | sed -e 's/ /,/g')
if tmux has-session -t "${session}"; then
    tmux kill-session -t "${session}"
    sleep 0.1
fi
tmux new-session -d -s "${session}" "htop -p $pids"
sleep 0.1
ONETERM_TITLE="filtered htop:${filter}" oneterminal "${session}"
```


## ~/bin/make-compile\_commands

```bash
#!/usr/bin/bash
#Maintained in linux-config.org
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
# Maintained in linux-config.org
pulseaudio -k &> /dev/null
pulseaudio -D &> /dev/null
start-pulseaudio-x11
```


## ~/bin/random-man-page

```bash
#!/usr/bin/bash
#Maintained in linux-config.org
page="$(find /usr/share/man/man1 -type f | sort -R | head -n1)"
eman "$page"
```


## ~/bin/remove-broken-symlinks

```bash
#!/usr/bin/bash
#Maintained in linux-config.org
find -L . -name . -o -type d -prune -o -type l -exec rm {} +
```


## ~/bin/remove-conflicted-copies

```bash
#!/usr/bin/bash
#Maintained in linux-config.org
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


## ~/bin/rgr-logger

```bash
#!/usr/bin/bash
#Maintained in linux-config.org
[ -z "$RGR_LOGGER" ] || logger "$@"
```


## ~/bin/sharemouse

```bash
#!/usr/bin/bash
#Maintained in linux-config.org
exec ssh -X ${1-192.168.2.100} x2x -east -to :0
```


## ~/bin/upd

update sw

```bash
#!/usr/bin/bash
# Maintained in linux-config.org
export DEBIAN_FRONTEND=noninteractive
sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean -y && sudo apt autoclean -y
```


## XMG Neo 15 Specifics


### ~/bin/xmg-neo-rgb-kbd-lights

See [XMGNeo 15 keyboard backlight controller](https://github.com/pobrn/ite8291r3-ctl) for the controller code.

```bash
#!/usr/bin/bash
#Maintained in linux-config.org

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
# Maintained in linux-config.org
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
    # Maintained in linux-config.org
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
#Maintained in linux-config.org
src=$1;shift;
dst=$1;shift;
txt=$@;
trans -e google -s ${src} -t ${dst} -show-original y -show-original-phonetics y -show-translation y -no-ansi -show-translation-phonetics n -show-prompt-message n -show-languages y -show-original-dictionary y -show-dictionary y -show-alternatives y "$txt"
```


### ~/bin/google-trans-de-en

```bash
#!/usr/bin/bash
#Maintained in linux-config.org
trans -e google -s de -t en -show-original y -show-original-phonetics y -show-translation y -no-ansi -show-translation-phonetics n -show-prompt-message n -show-languages y -show-original-dictionary y -show-dictionary y -show-alternatives y "$@"
```


### ~/bin/google-trans-en-de

```bash
#!/usr/bin/bash
#Maintained in linux-config.org
trans -e google -s en -t de -show-original y -show-original-phonetics y -show-translation y -no-ansi -show-translation-phonetics n -show-prompt-message n -show-languages y -show-original-dictionary y -show-dictionary y -show-alternatives y "$@"
```


## Security/Locking/GPG


### ~/bin/gpg-cache

```bash
#!/usr/bin/bash
#Maintained in linux-config.org
if ! pidof gpg-agent; then
    cachefile="${1:-"$HOME/.gnupg/auth/cache-keys"}"
    if [ -f "$cachefile" ]; then
        p=$(zenity --password --title "Password for SSH")
        if [ ! -z "$p" ]; then
            while IFS= read -r k; do
                [ ! -z "$p" ] && echo "$p" | /usr/lib/gnupg2/gpg-preset-passphrase --preset "$k"
            done < "$cachefile"
        fi
    fi
fi
```

\#+end\_src


### ~/bin/pre-lock

```bash
#!/usr/bin/bash
#Maintained in linux-config.org
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
#Maintained in linux-config.org
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
#Maintained in linux-config.org
command -v brightnessctl && brightnessctl -s
[ -f ~/.pre-blank ]  && . ~/.pre-blank
```


### ~/bin/post-blank

```bash
#!/usr/bin/bash
#Maintained in linux-config.org
[ -f ~/.post-blank ]  && . ~/.post-blank
command -v brightnessctl && brightnessctl -r
```


# tailends


## ~/.bash\_profile

```bash
[ -f "${HOME}/.bash_profile.local" ] && . "${HOME}/.bash_profile.local"
[ -f "${HOME}/.START_SWAY" ] && [ $(tty) = /dev/tty1 ] && exec sway
```


## Late addition to ~/.profile

```bash
[ -f "$HOME/.profile.local" ] && . "$HOME/.profile.local"
```