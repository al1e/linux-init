# Maintained in linux-init-files.org
logger -t "startup-initfile"  ZPROFILE
if [ -f ~/.profile ]; then
    emulate sh -c '. ~/.profile'
fi
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
