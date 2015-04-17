#!/bin/sh
#set -x

#Desgined to run in a crontab
#such as 
#*/3 * * * * /home/jlam/bin/screenshot.bash 2> ~/log/screenshot.crontab.log 2>&1

whoami=`whoami`
dest=/home/$whoami/screenshots/
file=/home/$whoami/$whoami-screenshot-`date +'%Y-%m-%d-%H-%M-%S'`.png
mkdir -p $dest
DISPLAY=:0 /usr/bin/scrot "$file"
mv -v $file $dest
find $dest -name '*png' -type f -mtime +30 -exec rm -v {} \;

