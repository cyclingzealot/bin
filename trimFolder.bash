#!/usr/bin/env bash

START=$(date +%s.%N)

#Set the config file
configFile='~/.binJlam/templateConfig'

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


target=${1:-}
maxsize=${2:-}  # In MB
suffix=${3:-log}


if [[ -z "$target" || -z "$maxsize" ]]; then
    echo
	echo Target and maxsize cannot be empty
    echo 2nd argument must be a number
    echo
	echo Usage: $__base target maxsize \(in MBs\)
    echo
	exit 1
fi


#Ensure only one copy is running
callID=`basename $target`$suffix$maxsize
pidfile=$HOME/.${__base}.$callID.pid
if [ -f ${pidfile} ]; then
   #verify if the process is actually still running under this pid
   oldpid=`cat ${pidfile}`
   result=`ps -ef | grep ${oldpid} | grep ${__base} || true`

   if [ -n "${result}" ]; then
     echo "Script already running! Exiting"
     exit 255
   fi
fi

#grab pid of this process and update the pid file with it
pid=`ps -ef | grep ${__base} | grep -v 'vi ' | head -n1 |  awk ' {print $2;} '`
echo ${pid} > ${pidfile}

# Create trap for lock file in case it fails
trap "rm -f $pidfile" INT QUIT TERM EXIT



echo Begin `date`  .....

### BEGIN SCRIPT ###############################################################

# Author
# that other guy
# http://stackoverflow.com/questions/25514434/bash-script-to-keep-deleting-files-until-directory-size-is-less-than-x#answer-25514993

loopThreshold=600

echo "Created pid file $pidfile"

loopBegin=`date +%s`
loopElapsed=0
while [ "$((du -shm $target || true) | awk '{print $1}')" -gt $maxsize -a "$loopElapsed" -lt "$loopThreshold" ]
do
  du -chs $target || true
  find $target -name "*.$suffix"  -type f -printf '%T@\t%p\n' | \
      sort -nr | tail -n 1 | cut -d $'\t' -f 2-  | xargs -d '\n' -I {} bash -c 'if ( lsof {} | grep {} ) || (! file --mime-encoding {} | grep binary) ; then echo "(Truncated by trimFolder.bash)" > {}; else rm -vf {}; fi'

  loopNow=`date +%s`
  echo "$loopElapsed=$loopNow-$loopBegin < $loopThreshold"
  let "loopElapsed=$loopNow-$loopBegin" || true
done

find $target -type d -empty -exec rmdir {} \; || true



### END SCIPT ##################################################################

END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo Done.  `date` - $DIFF seconds
