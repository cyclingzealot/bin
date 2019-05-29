#!/usr/bin/env bash

arg1=${1:-''}

if [[ $arg1 == '--help' || $arg1 == '-h' || -z "$1" ]]; then
    echo "You need to profile a file name"
    echo "Usage: $0 \$fileName"
    exit 0
fi


fileName=$1

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
#set -o xtrace


fileBaseName=`basename $fileName`
fileBaseName=`chopSuffix.bash $fileBaseName`
scratchPath=~/tmp/$fileBaseName


if [ -f $scratchPath ]; then
    rm -iv $scratchPath
fi

touch $scratchPath
chmod 600 $scratchPath

echo Making backup file
cp -vi $fileName $fileName.bak

gpg -d $fileName > $scratchPath

echo "Edit file $scratchPath"; sleep 1
vi $scratchPath

gpg -c $scratchPath

echo "Testing decrypt..."; sleep 1
gpg -d $scratchPath.gpg && mv -vi $scratchPath.gpg $fileName && rm -vi $scratchPath



set +x

### END SCIPT ##################################################################

cd $formerDir
