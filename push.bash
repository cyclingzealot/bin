#!/bin/bash

git commit -am "$1" 
echo
git pull && echo && git push 

echo 

git status


