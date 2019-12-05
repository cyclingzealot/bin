#!/usr/bin/env bash

arg1=${1:-''}

if [[ $arg1 == '--help' || $arg1 == '-h' ]]; then
    echo "Moves old files while preserving directory structure.  Not quite in a working state"
    echo "Usage: $0 {\$directory \$daysOld} [\$isTest]"
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

# If you require named arguments, see
# http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

export DISPLAY=:0

echo Begin `date`  .....

echo; echo; echo;

### BEGIN SCRIPT ###############################################################

#(a.k.a set -x) to trace what gets executed
set -o xtrace

moveFrom=`pwd`
targetDir=$1
daysOld=$2
isTest=${3:-''}

scratchFile=~/tmp/dirs.txt
mkdir -p ~/tmp/

find . -type d -print0 > $scratchFile

cd $targetDir

xargs -0 mkdir -p < $sratchFile

cd $moveFrom
if [ -z "isTest" ]; then
    find -mtime +$daysOld -exec bash -c "directoryBase=`dirname {}`; mv -vi {} $targetDir/$directoryBase/" \;
else
    find -mtime +$daysOld -exec bash -c "directoryBase=`dirname {}`; echo mv -vi {} $targetDir/$directoryBase/" \;
fi



rm $scratchFile
set +x

### END SCIPT ##################################################################

cd $formerDir
