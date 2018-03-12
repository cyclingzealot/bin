#!/usr/bin/env bash

arg1=${1:-''}

if [[ $arg1 == '--help' || $arg1 == '-h' ]]; then
    echo "Just specify the time (inclusive) of the first screenshot you wish to have. Time format HH:MM"
    exit 0
fi

#exit when command fails (use || true when a command can fail)
set -o errexit

#exit when your script tries to use undeclared variables
set -o nounset

# in scripts to catch mysqldump fails
set -o pipefail

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # Dir of the script
__root="$(cd "$(dirname "${__dir}")" && pwd)"           # Dir of the dir of the script
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"       # Full path of the script
__base="$(basename ${__file})"                          # Name of the script
ts=`date +'%Y%m%d-%H%M%S'`
ds=`date +'%Y%m%d'`
pid=`ps -ef | grep ${__base} | grep -v 'vi ' | head -n1 |  awk ' {print $2;} '`
formerDir=`pwd`

### BEGIN SCRIPT ###############################################################

#(a.k.a set -x) to trace what gets executed
#set -o xtrace

since=${1:-'00:00'}

scDir=$HOME/screenshots/

cd $scDir

sinceTS=`date -d "$since" +'%s'`
nowTS=`date +'%s'`;

minDiff=`echo "($nowTS - $sinceTS)/60 + 2" | bc | cut -d. -f 1`

noGoodCount=`find $scDir -mmin $minDiff -name '*.nogood.*' | wc -l `
numFilesToOpen=`find $scDir -mmin -$minDiff -name '*.png' | wc -l`
if [[  "$numFilesToOpen" != "0" ]]  > /dev/null ; then
    echo "Opening $numFilesToOpen files"
    if which eog; then
        eog `find $scDir -mmin -$minDiff -name '*.png' | sort`
    elif which xviewer; then
        xviewer `find $scDir -mmin -$minDiff -name '*.png' | sort`
    else
        echo NO VIEWER
    fi
fi
echo
echo $noGoodCount no good png files
echo


set +x

### END SCIPT ##################################################################

cd $formerDir
