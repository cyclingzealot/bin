#!/usr/bin/env bash

START=$(date +%s.%N)

#exit when command fails (use || true when a command can fail)
set -o errexit

#exit when your script tries to use undeclared variables
set -o nounset

#(a.k.a set -x) to trace what gets executed
#set -o xtrace

# in scripts to catch mysqldump fails 
set -o pipefail


while(true) ; do 
    ping -W 5 -c 1 $1 || notify-send "Can't reach router!"; 
    ping -W 5 -c1 www.credil.org || notify-send "Can't reach credil" ;  
    lynx -connect_timeout=15 --dump www.google.ca || notify-send "Can't reach google on http"; 
    sleep 5; 
done
