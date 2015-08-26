#!/bin/bash

#exit when command fails (use || true when a command can fail)
set -o errexit

#exit when your script tries to use undeclared variables
set -o nounset


### Commits everything, pulls and, if pull succesfull, pushes

git remote -v

echo

reportPath=''
if hash diffReport.bash 2>/dev/null; then
    reportPath=`diffReport.bash logOnly`
fi

set -x 
git commit -am "$1" 
echo
git pull && echo && git push 
set +x

echo 

git-branch-status.bash || true
git submodule foreach git-branch-status.bash || true



if [[ ! -z "$reportPath" ]] ; then
	echo; echo; echo
	echo Diff report in
	echo $reportPath
	echo; echo; echo
fi
	

#echo 'Repacking.... this will be eventually in a seperate term window'
#git repack -a -d --depth=250 --window=250
