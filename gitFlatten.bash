#!/usr/bin/env bash

arg1=${1:-''}


function printHelp {
    echo "$0 {--source|-s}=source {--target|-t}=target"
    echo "source is the repo which the directory will come from"
    echo "target is the directory where all the branches will go"
    echo "Any changes in the source will be written into the target using rsync"
    exit 0
}

if [[ $arg1 == '--help' || $arg1 == '-h' || -z "$2" ]]; then
    printHelp
fi

#exit when command fails (use || true when a command can fail)
set -o errexit

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
    -s=*|--source=*)
    sourceRepo="${i#*=}"
    shift # past argument=value
    ;;
    -t=*|--target=*)
    targetDir="${i#*=}"
    shift # past argument=value
    ;;
    *)
    # unknown option
    ;;
esac
done


if [[ -z "$sourceRepo" || -z "$targetDir" ]]; then
    printHelp
fi

#exit when your script tries to use undeclared variables
set -o nounset


#Capture everything to log
mkdir -p ~/log
log=~/log/$__base-${ts}.log
exec >  >(tee -a $log)
exec 2> >(tee -a $log >&2)
touch $log
chmod 600 $log



export DISPLAY=:0

echo Begin `date`  .....

echo; echo; echo;

### BEGIN SCRIPT ###############################################################


oldPwd=`pwd`
oldBranch=`$__dir/currentBranch.bash`


if [[ ! -d "$sourceRepo" ]]; then
    echo "The sourceRepo is not a valid dir"
    exit 1
fi

if [[ ! -d "$targetDir" ]]; then
    echo "The targetDir is not a valid dir"
    exit 1
fi



for branch in `git for-each-ref --format "%(refname:short)" refs/heads`; do
    cd $sourceRepo
    sourceBn=`basename $sourceRepo`
    git checkout $branch
    git pull || true
    echo "From `pwd`, rsyncing with branch $branch checked out"
    set -o xtrace
    rsync -av --exclude='.git/' . $targetDir/$branch/
    set +x
done

find -maxdepth 2 -type d $targetDir


set +x

cd $oldPwd

### END SCIPT ##################################################################

cd $formerDir
