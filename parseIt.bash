#!/bin/bash

while(true); do
    read file
    validateJSON.bash $file > /dev/null 2>&1
    result=$?
   
    if [ "$result" -eq "0" ] ; then
        jsonPrettyPrint.bash $file
    else 
        cat $file | lynx --stdin
    fi
done
