#!/bin/bash


numProcs=1

while [[ "$numProcs" -gt 0 ]]; do


#set -x
numProcs=`ps -ef | grep $1 | grep -v grep | grep -v untilDone | wc -l`

if [[ "$numProcs" -gt 0 ]]; then 
	printf . ; 
	sleep 1; 
	#echo ; 
	#ps -ef | grep $1 ; 
	#echo ; 
fi


done
