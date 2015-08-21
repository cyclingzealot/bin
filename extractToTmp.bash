#!/bin/bash

# Extracts all the *.gz files to tmp

for file in *.gz ; do 
    target=/tmp/`echo $file | rev | cut -d '.' -f 2- | rev` ; 

    if [ -f $target ]; then 
    
        ls -lh $target;  
        read -p "Do you wish to overwrite this file? (Y/N) " yn
        
        if [[ ! "$yn" =~ ^[Yy] ]]; then
            echo Answer did not contain Y or y.  Not overwritting.
            continue        
        fi
    
    fi

    gzip -dcv $file > $target; 
    ls -lh $target;  
done
