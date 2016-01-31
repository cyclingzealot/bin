#!/bin/bash

IFS=$'\n'

for file in ./*.pdf ; do  
    pdftotext $file -; 
    echo; 
done  | grep 201 | sort | uniq | grep -oe '[A-Z][a-z]\{2\} [0-9]\{2\}, [0-9]\{4\}' | sort | uniq > /tmp/datesFound.txt 

for mois in `cat /tmp/datesFound.txt` ; do
    date -d"$mois" +'%Y%m'
done | sort | uniq
