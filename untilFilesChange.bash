#!/bin/bash


files=$@
set -o pipefail
oldTS=`stat -c %Y $files | sort -n  | tail -n 1`
newTS=$oldTS

while [ "$oldTS" -eq "$newTS" ]; do
    printf . ;
    newTS=`stat -c %Y $files | sort -n  | tail -n 1`
    sleep 1
done

echo
echo In $PWD, $files changed, proceeding....
