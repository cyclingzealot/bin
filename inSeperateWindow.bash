#!/usr/bin/env bash

START=$(date +%s.%N)

#exit when command fails (use || true when a command can fail)
set -o errexit

#exit when your script tries to use undeclared variables

#(a.k.a set -x) to trace what gets executed
set -o xtrace

# in scripts to catch mysqldump fails 
set -o pipefail

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
ts=`date +'%Y%m%d-%H%M%S'`

#Set the config file
configFile='~/.binJlam/templateConfig'


#Capture everything to log
log=~/log/$__base-${ts}.log
#exec >  >(tee -a $log)
#exec 2> >(tee -a $log >&2)
#touch $log
#chmod 600 $log


#Check that the config file exists
#if [[ ! -f "$configFile" ]] ; then
#        echo "I need a file at $configFile with ..."
#        exit 1
#fi


#echo Begin `date`  .....

### BEGIN SCRIPT ###############################################################

cmd=''
if [[ -z "$1" ]]; then 
	cmd='echo Use me to launch a command in a seperate gnome-terminal window.  Very usefull for sudo things...; sleep 5; echo Closing in 5 seconds.... ; sleep 5'
else
	cmd=$1
fi
set -o nounset

gnome-terminal -x bash -c "$cmd"


### END SCIPT ##################################################################

#END=$(date +%s.%N)
#DIFF=$(echo "$END - $START" | bc)
#echo Done.  `date` - $DIFF seconds
