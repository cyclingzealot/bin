#!/bin/sh
#set -x

#Desgined to run in a crontab
#such as 
#*/3 * * * * /home/jlam/bin/screenshot.bash 2> ~/log/screenshot.crontab.log 2>&1


#Author:  Shambhu Singh http://www.tecmint.com/take-screenshots-in-linux-using-scrot/
#Author: jlam@credil.org

whoami=`whoami`
dest=/home/$whoami/screenshots/
file=/home/$whoami/$whoami-screenshot-`date +'%Y-%m-%d-%H-%M-%S'`.png
mkdir -p $dest
DISPLAY=:0 /usr/bin/scrot "$file"
mv -v $file $dest


#Author
#That other guy
#http://stackoverflow.com/questions/25514434/bash-script-to-keep-deleting-files-until-directory-size-is-less-than-x#25514993o
#jlam@credil.org

maxsize=500 #In MBs
while [ "$(du -shm $dest | awk '{print $1}')" -gt $maxsize ]
do
  find $dest -maxdepth 1 -type f -printf '%T@\t%p\n' | \
      sort -n | head -n 25 | cut -d $'\t' -f 2-  | xargs -d '\n' rm -v
done

