#!/usr/bin/env bash

START=$(date +%s.%N)

#Set the config file
configFile="$HOME/.currentDisplay"

#exit when command fails (use || true when a command can fail)
set -o errexit

#exit when your script tries to use undeclared variables
set -o nounset

#(a.k.a set -x) to trace what gets executed
#set -o xtrace

# in scripts to catch mysqldump fails
set -o pipefail

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
ts=`date +'%Y%m%d-%H%M%S'`


#Capture everything to log
log=~/log/$__base-${ts}.log
exec >  >(tee -a $log)
exec 2> >(tee -a $log >&2)


#Check that the config file exists
if [[ ! -f "$configFile" ]] ; then
        echo "I need a file at $configFile with the current display.  You may want to put this in your bashrc:"
        echo "echo \$DISPLAY > ~/.currentDisplay"
        exit 1
fi


echo Begin `date`  .....

### BEGIN SCRIPT ###############################################################

#Desgined to run in a crontab
#such as
#*/3 * * * * /home/jlam/bin/screenshot.bash 2> ~/log/screenshot.crontab.log 2>&1


idleTime=''
display=`cat $configFile`
echo "Display obtained is"
echo $display
idleTime=`DISPLAY=$display xprintidle` || echo "Unable to get idle time"
export DISPLAY=$display

if [[ "$idleTime" -gt 1800000 ]] ; then
	echo "Computer has been idle for more than 30 minutes, exiting with no screenshot"
	exit 0
else  echo Idle time is $idleTime
fi


#Author:  Shambhu Singh http://www.tecmint.com/take-screenshots-in-linux-using-scrot/
#Author: jlam@credil.org

whoami=`whoami`
dest=/home/$whoami/screenshots/
file=$dest/$whoami-screenshot-`date +'%Y-%m-%d-%H-%M-%S'`.png
mkdir -p $dest
#DISPLAY=$display /usr/bin/scrot "$file"
timeout --kill-after=2s 2s /usr/bin/scrot "$file" || echo "ERROR: Unable to take screenshot within alloted time"
if [ -f $file ] ; then
    chmod 600 $file;
    if which pngcheck && ! pngcheck $file ; then
        mv -v $file $file.nogood
    fi
fi

if ! which pngcheck ; then
    echo NO PNGCHECK
fi


#Author
#That other guy
#http://stackoverflow.com/questions/25514434/bash-script-to-keep-deleting-files-until-directory-size-is-less-than-x#25514993o
#jlam@credil.org

maxsize=500 #In MBs
while [ "$(du -shm $dest | awk '{print $1}')" -gt $maxsize ]
do
  find $dest -maxdepth 1 -type f -name '*.png*' -printf '%T@\t%p\n' | \
      sort -nr | tail -n 1 | cut -d $'\t' -f 2-  | xargs -d '\n' rm -v
done

### END SCIPT ##################################################################

END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo Done.  `date` - $DIFF seconds
