#!/bin/sh
#set -x
whoami=`whoami`
dest=/home/$whoami/screenshots/
file=/home/$whoami/$whoami-screenshot-%Y-%m-%d-%H_%M.png
filemv=/home/$whoami/$whoami-screenshot-*.png
mkdir -p $dest
DISPLAY=:0 /usr/bin/scrot "$file"
mv -v $filemv $dest
find $dest -name '*png' -type f -mtime +30 -exec rm -v {} \;

