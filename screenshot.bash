#!/bin/sh
#set -x
whoami=`whoami`
dest=/home/$whoami/screenshots/
file=/home/$whoami/$whoami-screenshot-`date +'%Y-%m-%d-%H-%M-%S'`.png
mkdir -p $dest
DISPLAY=:0 /usr/bin/scrot "$file"
mv -v $file $dest
find $dest -name '*png' -type f -mtime +30 -exec rm -v {} \;

