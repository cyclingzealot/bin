#!/bin/bash


re='^[0-9]+$'

if [[ "$1" =~ $re ]]; then
    secs=$1

    mins=${2:-''}

    if [[ "$mins" == 'm' ]]; then
        secs=$((60*$secs))
    fi


	 for i in `seq $secs -1 0`; do
     printf "$i... " ;
     sleep 1;

     if [ `expr $i % 15` -eq 0 ]; then
        printf "       \r";
     fi
    done
	exit 0
fi

echo 'No number specified... counting up....'
i=0
while(true); do
    printf "$i... " ;
    sleep 1;
    let i++;

     if [ `expr $i % 15` -eq 0 ]; then
        printf "       \r";
     fi
done
