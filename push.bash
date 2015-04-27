#!/bin/bash

### Commits everything, pulls and, if pull succesfull, pushes

git remote -v

echo

reportPath=''
if hash diffReport.bash 2>/dev/null; then
    set -x
    reportPath=`diffReport.bash logOnly`
fi

set -x 
git commit -am "$1" 
echo
git pull && echo && git push 

echo 

git status

if [[ ! -z "$reportPath" ]] ; then
	echo; echo; echo
	echo Diff report in
	echo $reportPath
	echo; echo; echo
fi
	

#echo 'Repacking.... this will be eventually in a seperate term window'
#git repack -a -d --depth=250 --window=250
