#!/bin/bash


numProcs=0

while [[ "$numProcs" -eq 0 ]]; do


#set -x
numProcs=`ps -ef | grep $1 | grep -v grep | grep -v untilUp | wc -l`

if [[ "$numProcs" -eq 0 ]]; then 
	printf . ; 
	sleep 1; 
	#echo ; 
	#ps -ef | grep $1 ; 
	#echo ; 
fi


done
