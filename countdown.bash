#!/bin/bash


re='^[0-9]+$'

if [[ "$1" =~ $re ]]; then
	 for i in `seq $1 -1 0`; do printf "$i... " ; sleep 1; done
	exit 0
fi

echo 'No number specified... counting up....'
i=0
while(true); do printf "$i... " ; sleep 1; let i++; done
