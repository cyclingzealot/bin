#!/bin/bash

#exit when command fails (use || true when a command can fail)
set -o errexit

#exit when your script tries to use undeclared variables
set -o nounset

if [ ! -f $1.2 ]; then
    sort $1 > $1.2
else
    echo $1.2 exists
    exit 1
fi

mv -vf $1.2 $1

seperator.bash
cat $1
echo
