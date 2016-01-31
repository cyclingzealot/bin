#!/bin/bash

# Goes through all pdf files, looking for date formats 
#   shortMonth date, year
# Transforms those dates into YYYYMM, sort and uniqs them.  
# You can then check if you have all months in your bills.


IFS=$'\n'

for file in ./*.pdf ; do  
    pdftotext $file -; 
    echo; 
done  | grep 201 | sort | uniq | grep -oe '[A-Z][a-z]\{2\} [0-9]\{2\}, [0-9]\{4\}' | sort | uniq > /tmp/datesFound.txt 

for mois in `cat /tmp/datesFound.txt` ; do
    date -d"$mois" +'%Y%m'
done | sort | uniq


rm /tmp/datesFound.txt
