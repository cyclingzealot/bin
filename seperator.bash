#!/bin/bash

char=${2:-'#'}
length=${1:-`tput cols`}

if [ "$1" == "-h" ] ;  then
	echo $0 length char
	exit
fi

yes "$char" |  head -n $length | tr -d "\n" | xargs echo
