#!/bin/bash

cb=`git branch | grep '*' | cut -d ' ' -f 2`

git checkout master && git merge $cb && push.bash "Merged with $cb and pushed to origin" && git checkout $cb 
