#!/bin/bash


file=$1
set -o pipefail
oldTS=`stat -c %Y $file`
newTS=$oldTS

while [ "$oldTS" -eq "$newTS" ]; do 
    printf . ; 
    sleep 1
    newTS=`stat -c %Y $file`
done

echo
echo $file changed, proceeding....
