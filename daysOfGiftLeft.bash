#!/bin/bash



lastRunFile="$HOME/.`basename $0`.lastRun"

if [[ -f $lastRunFile &&  `expr $(date +%s) - $(date +%s -r $lastRunFile)` -lt 4 ]]; then
    exit 0
else
    touch $lastRunFile
fi



NAISSANCE=`date -d '1981/07/09 8:13' +'%s'`
ESP=88
maintenant=`date +'%s'`
ESPsecs=`echo $ESP*365.25*24*60*60 | bc`


fin=`echo $NAISSANCE+$ESPsecs | bc`


joursRestant=`echo "($fin-$maintenant)/(24*60*60)" | bc| cut -d. -f 1`

echo "$joursRestant jours restant"

