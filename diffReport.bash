#!/usr/bin/env bash

START=$(date +%s.%N)

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

#Set the config file
configFile='~/.binJlam/templateConfig'


#Capture everything to log
log=~/log/$__base-${ts}.log
exec >  >(tee -a $log)
exec 2> >(tee -a $log >&2)


#Check that the config file exists
#if [[ ! -f "$configFile" ]] ; then
#        echo "I need a file at $configFile with ..."
#        exit 1
#fi



### BEGIN SCRIPT ###############################################################

topPath=`git rev-parse --show-toplevel`
prjName=`basename $topPath`
whoami=`whoami`

reportPath=/tmp/$whoami-$prjName-$ts.diff


### By default, the script runs standalone, output AND tees the diff to a path, 
set -x
if [[ -z "$1" ]]; then
	git diff | tee $reportPath

	echo ; echo ; echo
	echo Report in:
	echo 
	echo $reportPath

	echo ; echo ; echo
### If any argument is supplied, just output the path so it can be used 
### within an other script (such as push.bash)
else 
	git diff > $reportPath
	printf $reportPath
fi




### END SCIPT ##################################################################
