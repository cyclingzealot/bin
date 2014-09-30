#!/bin/bash

git remote -v

echo

set -x 
git commit -am "$1" 
echo
git pull && echo && git push 

echo 

git status

#echo 'Repacking.... this will be eventually in a seperate term window'
#git repack -a -d --depth=250 --window=250
