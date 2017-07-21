#!/bin/bash

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


echo Chekcing and waiting until git finishes.....

untilDone.bash -s git -e "$__base"

### Commits everything, pulls and, if pull succesfull, pushes

git remote -v

echo

reportPath=''
if hash diffReport.bash 2>/dev/null; then
    reportPath=`diffReport.bash logOnly`
fi

echo Git commit...
git commit -am "$1"  || true
echo

echo Submodule check...
cd `git rev-parse --show-toplevel`
git submodule init
git submodule update
cd -
echo

echo 'git pull & git push'
git pull && echo && git push
set +x

echo

git-branch-status.bash || true
git submodule foreach --recursive git-branch-status.bash || true




if [[ ! -z "$reportPath" ]] ; then
	echo; echo; echo
	echo Diff report in
	echo $reportPath
	echo; echo; echo
fi


#echo 'Repacking.... this will be eventually in a seperate term window'
#git repack -a -d --depth=250 --window=250
