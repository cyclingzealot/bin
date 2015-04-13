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
log=/dev/null 
if [ -d /mnt/tmp/ ]; then
	log=/mnt/tmp/$__base.log # Uncomment to debug
fi
exec >  >(tee -a $log)
exec 2> >(tee -a $log >&2)


#Check that the config file exists
#if [[ ! -f "$configFile" ]] ; then
#        echo "I need a file at $configFile with ..."
#        exit 1
#fi


echo Begin `date`  .....

### BEGIN SCRIPT ###############################################################

export DISPLAY=:0.0
batteryPct=`acpi | cut -d ' ' -f 4 | sed -n 's/,$//p'`
batteryNoPct=${batteryPct%%'%'}
random=$((  RANDOM % 100  ))

echo $batteryPct $batteryNoPct $random

if [ "$batteryNoPct" -le "$random" ]; then
	notify-send "Pile à $batteryPct"
else 
	echo "False: $batteryPct < $random"
fi


### END SCIPT ##################################################################

END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo Done.  `date` - $DIFF seconds
