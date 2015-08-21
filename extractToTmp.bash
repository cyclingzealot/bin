#!/bin/bash

# Extracts all the *.gz files to tmp

for file in *.gz ; do 
    target=`echo $file | rev | cut -d '.' -f 2- | rev` ; 
    gzip -dcv $file > /tmp/$target; 
    ls -l  /tmp/$target;  
done
