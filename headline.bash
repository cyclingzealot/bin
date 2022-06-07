#!/bin/bash

term=$1
char=${2:-'='}
length=${3:-150}

if [[ "$length" -eq -1 ]]; then
    length=`tput cols `
fi

if [ "$1" == "-h" ] ;  then
	echo $0 {term} [char length]
	exit
fi


remainder=`echo "$length - 3 - ${#term} - 2" | bc`

yes "$char" | head -n 3             | tr -d "\n" | xargs echo -n
echo -n " $term "
yes "$char" |  head -n $remainder   | tr -d "\n" | xargs echo
