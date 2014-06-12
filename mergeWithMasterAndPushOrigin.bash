#!/bin/bash

cb=`git branch | grep '*' | cut -d ' ' -f 2`

git checkout master && git merge $cb && push.bash && git checkout $cb 
