#!/usr/bin/env bash

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
configFile="$HOME/.binJlam/$__base.conf"

defaultBase=https://meet.jit.si/

arg1=${1:-''}

if [[ $arg1 == '--help' || $arg1 == '-h' ]]; then
    echo "Usage: $0 \$meetingTopic \$baseUrl"
    echo "You can use $configFile like defaultBase=\$baseUrl to override the default  $defaultBase"
    exit 0
fi

#exit when command fails (use || true when a command can fail)
set -o errexit

#exit when your script tries to use undeclared variables
set -o nounset

# in scripts to catch mysqldump fails
set -o pipefail

# If you require named arguments, see
# http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

export DISPLAY=:0

#echo Begin `date`  .....
#echo; echo; echo;

### BEGIN SCRIPT ###############################################################

#(a.k.a set -x) to trace what gets executed
#set -o xtrace


if [ -f $configFile ]; then
    . $configFile
fi

meetingTopic=$1
baseUrl=${2:-"$defaultBase"}

hash=$(echo $meetingTopic | sha1sum | cut -c 1-10)


echo $baseUrl/$meetingTopic-$hash


set +x

### END SCIPT ##################################################################

cd $formerDir
