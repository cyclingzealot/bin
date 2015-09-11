#!/bin/bash 

currentPWD=`pwd`;  for dir in `find ~/code/ -maxdepth 2 -name .git  -type d`; do echo `dirname $dir` ; cd `dirname $dir` ; git-branch-status.bash; git submodule foreach --recursive git-branch-status.bash;  done; cd $currentPWD;

