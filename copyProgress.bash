#!/bin/bash


baseTime=`date +'%s'`
baseOneSize=$sizeOne

sizeOne=`du -b $1 | cut -f 1`
sizeTwo=`du -b $2 | cut -f 1`

baseSizeTwo=$sizeTwo


while [ $sizeOne -gt $sizeTwo ] ; do
    sizeOne=`du -b $1 | cut -f 1`
    sizeTwo=`du -b $2 | cut -f 1`

    nowTime=`date +'%s'`
    nowSizeTwo=$sizeTwo

    rate=`echo "scale=10; ($nowSizeTwo-$baseSizeTwo)/($nowTime-$baseTime)" | bc `

    etcMins=`echo "(($sizeOne-$sizeTwo)/$rate)/60" | bc`
    etcHours=`echo "scale=1; $etcMins/60" | bc`

    rate=`echo "scale=2; $rate" | bc`


    

#ls -lh $1 $2

   pct=$((( 100 * $sizeTwo ) / $sizeOne ))

   echo '#' $pct %  - $etcMins mins - $etcHours hours - $rate bytes/sec

   ls -lb $1 $2

   echo; echo;

sleep 2; 

done
