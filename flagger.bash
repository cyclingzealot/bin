#!/usr/bin/env bash

arg1=${1:-''}

if [[ $arg1 == '--help' || $arg1 == '-h' ]]; then
    echo "Provide flag name as first arg and seconds to green as second argument"
    exit 0
fi

#exit when command fails (use || true when a command can fail)
#set -o errexit

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

# If you require named arguments, see
# http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

export DISPLAY=:0

echo Begin `date`  .....

echo; echo; echo;

### BEGIN SCRIPT ###############################################################

#(a.k.a set -x) to trace what gets executed
set -o xtrace

flagsDir=$HOME/.flagger/
mkdir -p $flagsDir

flagName=$1
secsToGreen=$2
flagPath=$flagsDir/$flagName

green=0

if [ "$secsToGreen" -lt "0" ]; then
    # Threshold is a negative number, so we clear the flag,
    # giving a green next time, right away
    # we wish time elapsed since the last event we let pass
    # Flagger.bash will exit 0 however, indicating normal operation
    rm $flagPath
    exit 0
elif [[ ! -f "$flagPath" ]]; then
    # We've never been asked to keep tabs on this flag, so you can go
    green=1
elif [[ `~/bin/secsSinceMod.bash $flagPath` -gt "$secsToGreen" ]]; then
    # It's been more seconds since your threshold that this event happened, so you can go
    green=1
else
    # It's been fewer seconds since your threshold that this event happened, so no, stop
    green=0
fi

if [[ "$green" -eq "0" ]]; then
    # You can't go: exit 1 so flagger.bash && $otherScript does not run
    exit 1
elif [[ "$green" -eq "1" ]]; then
    # You can go, so we will touch the flag, and exit 0 so flagger.bash && $otherScript runs
    touch $flagPath
    exit 0
fi
