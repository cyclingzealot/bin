#!/usr/bin/env bash

arg1=${1:-''}

if [[ $arg1 == '--help' || $arg1 == '-h' ]]; then
    echo "Get calendar for a month using YYYY MM format or YYYY/MM format"
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

month=${2:-''}
year=${1:-''}


if [[ -z "$month" ]]; then
    month=`echo $1 | cut -d '/' -f 2`
    year=`echo $1 | cut -d '/' -f 1`
fi

cal $month $year






set +x

### END SCIPT ##################################################################

cd $formerDir
