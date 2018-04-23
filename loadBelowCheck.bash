#!/usr/bin/env bash

arg1=${1:-''}

if [[ $arg1 == '--help' || $arg1 == '-h' || -z $arg1 ]] ; then
    echo "Must provide load theshold:"
    echo "$0 \$loadThreshold"
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

for i in "$@"
do
case $i in
    -r|--repeat)
    REPEAT="true"
    shift # past argument=value
    ;;
    -t=*|--threshold=*)
    loadTH="${i#*=}"
    shift # past argument=value
    ;;
    *)
          # unknown option
    ;;
esac
done


export DISPLAY=:0

echo; echo; echo;

### BEGIN SCRIPT ###############################################################

#(a.k.a set -x) to trace what gets executed

cycles=0
while  [[ $cycles -eq 0  || "$REPEAT" = "true" ]] ; do
sleep 1
loadavg=`uptime | awk '{print $10+0}'`
# bash doesn't understand floating point
# so convert the number to an interger
thisloadavg=`echo $loadavg|awk -F \. '{print $1}'`
exitCode=1
if [ "$thisloadavg" -ge "$loadTH" ]; then
 if (( $cycles == 0 )) ; then
    echo -n "Busy - Load Average ";
 fi

 echo -n "$thisloadavg... "
 sleep 1
else
 exitCode=0
 REPEAT="false"
fi
let cycles++ || true
done

exit $exitCode

### END SCIPT ##################################################################

