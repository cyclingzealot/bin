#!/usr/bin/env bash

# Requires 
# libdate-calc-perl (or Date::calc), 
# perl -MCPAN -e install Geo::Hashing 
# and of course the geoHashHistory.pl script

START=$(date +%s.%N)

#Set the config file
configFile='~/.binJlam/templateConfig'

#exit when command fails (use || true when a command can fail)
set -o errexit

#exit when your script tries to use undeclared variables
set -o nounset

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


#Capture everything to log
log=~/log/$__base-${ts}.log
exec >  >(tee -a $log)
exec 2> >(tee -a $log >&2)


#Check that the config file exists
#if [[ ! -f "$configFile" ]] ; then
#        echo "I need a file at $configFile with ..."
#        exit 1
#fi


echo Begin `date`  .....

### BEGIN SCRIPT ###############################################################

complete=~/.geoHistoryWrapper.modflag

mod=0
if [ -f $complete ]; then 
	mod=$(date -r $complete  +%s)
fi
now=$(date +%s) 
days=$(expr \( $now - $mod \) / 86400)

if [ "$days" -gt 30 ]; then
	for long in -73 -75 -76; do
		$__dir/geoHashHistory.pl 45 $long > ~/tmp/geoHashHistory_45${long}.xml
	done
	touch $complete
else 
	echo Not redoing geoHashHistory as complete file is $days old
fi

$__dir/globalHashHistory.pl  > ~/tmp/geoHashHistory_global.xml



### END SCIPT ##################################################################

END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo Done.  `date` - $DIFF seconds
