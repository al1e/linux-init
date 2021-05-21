# Maintained in linux-init-files.org
rgr-logger -t "startup-initfile"  ZPROFILE
if [ -f ~/.profile ]; then
    emulate sh -c '. ~/.profile'
fi
