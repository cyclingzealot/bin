#!/usr/bin/env bash

arg1=${1:-1000}

if [[ $arg1 == '--help' || $arg1 == '-h' ]]; then
    echo "Script author should have provided documentation"
    exit 0
fi

thresholdNum=${1:-1000}

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

#Set the config file
configFile="$HOME/.timeUntil.conf"
#Check that the config file exists
if [[ ! -f "$configFile" ]] ; then
        echo "I need a file at $configFile with an entry like"
        echo "\$targetDateTime;\$string"
        exit 1
fi


# If you require named arguments, see
# http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

export DISPLAY=:0

#echo Begin `date`  .....

#echo; echo; echo;

### BEGIN SCRIPT ###############################################################

#(a.k.a set -x) to trace what gets executed
#set -o xtrace

function genUntilString {
    targetTS=`date -d $1 +'%s'`
    maintenant=`date +'%s'`
    diffTS=`echo $targetTS-$maintenant | bc`

    timeUnit='s'
    diffTime=$diffTS

    while [ $diffTime -ge "$thresholdNum" ] && [ $timeUnit != 'années' ]; do
        case "$timeUnit" in
        s)
            timeUnit='min'
            let diffTime=diffTime/60
            ;;
        min)
            timeUnit='hrs'
            let diffTime=diffTime/60
            ;;
        hrs)
            timeUnit='jours'
            let diffTime=diffTime/24
            ;;
        jours)
            timeUnit='semaines'
            let diffTime=diffTime/7
            ;;
        semaines)
            timeUnit='mois'
            let diffTime=diffTime*7/365*12
            ;;
        mois)
            timeUnit='années'
            let diffTime=diffTime/12
            ;;
        esac
    done

    echo $diffTime $timeUnit
    echo ''

}

IFS=$'\n'
for line in `grep -v '#' $configFile | sort`; do
    targetDateTime=`echo $line | cut -d';' -f 1`
    string=`echo $line | cut -d';' -f 2`

    if [[ `date '+%s' -d $targetDateTime` -ge `date '+%s'` ]]; then
        untilString=$(genUntilString $targetDateTime)
        echo $string $'\t' $untilString
    fi

done

set +x

### END SCIPT ##################################################################

cd $formerDir
