#!/bin/bash

cb=`git branch | grep '*' | cut -d ' ' -f 2`

### Run test then git commit
phpunit --stop-on-failure --configuration /home/jlam/code/ArtsandCultureCalendar/Symfony/app/phpunit.xml && 
push.bash "$1" && 

## Merge with master
[[ `git status` =~ "working directory clean" ]] && 
git checkout master && 
git pull &&
git merge $cb && 

### Run tests and push to master
phpunit --stop-on-failure --configuration /home/jlam/code/ArtsandCultureCalendar/Symfony/app/phpunit.xml  && 
push.bash && 

echo && 
echo "Done!!!!   " `date`  && 
echo
