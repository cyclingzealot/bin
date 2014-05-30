#!/bin/bash

git remote -v

echo

set -x 
git commit -am "$1" 
echo
git pull && echo && git push 

echo 

git status


