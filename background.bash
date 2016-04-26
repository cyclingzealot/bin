#!/bin/bash

#exit when command fails (use || true when a command can fail)
set -o errexit

#exit when your script tries to use undeclared variables
set -o nounset

set -x

command=$1
name=$(echo "$command" | sed -e 's/[^A-Za-z0-9._-]/_/g')

ts=`date +'%Y%m%d-%H%M%S'`

#Capture everything to log
log=~/log/$name-${ts}.log

#screen -dmS $name bash -c "$command 2>&1 | tee $log" ;
gnome-terminal -x bash -c "$command 2>&1 | tee $log; echo ; echo DONE ; echo ; countdown.bash 10"
