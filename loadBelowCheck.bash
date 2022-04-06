#!/usr/bin/env bash

arg1=${1:-''}

if [[ $arg1 == '--help' || $arg1 == '-h' || -z $arg1 ]] ; then
    echo "Must provide load theshold:"
    echo "$0 -t="
    echo
    echo "Optional args:"
    echo "-r=|--repeat=    Wait until the load is at the right level rather than just do one test"
    echo "-v |--verbose    Be a bit more verbose"
    exit 2
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

# If you require named arguments, see
# http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

verbose='false'
lookAtWait="false"
REPEAT="false"
for i in "$@"
do
case $i in
    -r|--repeat)
    REPEAT="true"
    echo "Will do continuous loop"
    shift # past argument=value
    ;;
    -t=*|--threshold=*)
    loadTH="${i#*=}"
    echo "Threshold set to $loadTH"
    shift # past argument=value
    ;;
    -w|--waiting)
    lookAtWait="true"
    echo "Will look at wait"
    shift # past argument=value
    ;;
    -v|--verbose)
    verbose="true"
    echo "Will be verbose"
    shift # past argument=value
    ;;
    *)
    echo "Unknown option $i"
esac
done


export DISPLAY=:0

echo; echo; echo;

### BEGIN SCRIPT ###############################################################

#(a.k.a set -x) to trace what gets executed

cycles=0
while  [[ $cycles -eq 0  || "$REPEAT" = "true" ]] ; do
sleep 1

what=''
loadavg=''
if [[ "$lookAtWait" == "true" ]] ; then
    echo "Not implemented"
    exit 1
    loadavg=`top -b  -n 1 | head -n 3 | tail -n 1 | tr -s ' ' | cut -d ' ' -f 10 | cut -d , -f 1 | cut -d. -f 1`
    what='number of waiting processes'
else
    loadavg=`uptime | awk '{print $8+0}'`
    what='load average'
fi

# bash doesn't understand floating point
# so convert the number to an interger
thisloadavg=`echo $loadavg|awk -F \. '{print $1}'`
exitCode=1
if [ "$thisloadavg" -ge "$loadTH" ]; then
 if (( $cycles == 0 )) ; then
    echo -n "Busy - $what ";
 fi

 echo -n "$thisloadavg... "
 sleep 1
else
 if [ "$verbose" == 'true' ]; then
    echo "load average is $thisloadavg < $loadTH .  Exiting"
 fi
 exitCode=0
 REPEAT="false"
fi
let cycles++ || true
done

exit $exitCode

### END SCIPT ##################################################################

