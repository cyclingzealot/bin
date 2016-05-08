#!/bin/bash

NAISSANCE=`date -d '1981/07/09 8:13' +'%s'`
ESP=88
maintenant=`date +'%s'`
ESPsecs=`echo $ESP*365.25*24*60*60 | bc`


fin=`echo $NAISSANCE+$ESPsecs | bc`


joursRestant=`echo "($fin-$maintenant)/(24*60*60)" | bc| cut -d. -f 1`

echo "$joursRestant jours restant"

