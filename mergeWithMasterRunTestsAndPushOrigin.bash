#!/bin/bash

cb=`git branch | grep '*' | cut -d ' ' -f 2`

phpunit && push.bash $1 && [[ `git status` =~ "working directory clean" ]] && git checkout master && git merge $cb && phpunit && push.bash && echo && echo "Done!!!!   " `date`  && echo
