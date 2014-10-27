#!/bin/bash

set -x

numProcs=1

while [[ "$numProcs" -gt 0 ]]; do


numProcs=`ps -ef | grep $1 -c`

numProcs=`echo $numProcs - 3 | bc`

if [[ "$numProcs" -gt 0 ]]; then printf . ; sleep 1; ps -ef | grep $1 ; fi


done
