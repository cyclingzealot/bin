#!/usr/bin/env bash

arg1=${1:-''}

if [[ $arg1 == '--help' || $arg1 == '-h' ]]; then
    echo "Start tmux session and new branch both named after argument given"
    echo "Be sure you are checking out from branch name you want"
    echo "Usage: $0 \$branchAndSessionName"
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

if [ -z "$arg1" ]; then
    echo "Need tmux session name and branch name"
    exit 1
fi

if git show-ref --quiet "refs/heads/$arg1"; then
    git checkout $arg1
else
    git checkout -b "$arg1"
fi

if tmux list-sessions | grep $arg1 ; then
    tmux attach -t "$arg1"
else
    tmux new -s "$arg1"
fi


set +x

### END SCIPT ##################################################################

cd $formerDir
