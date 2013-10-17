#/bin/bash

filter=''
if [ -z "$1" ]; then
	filter='-type f' 
else
	filter="-name $1"
fi

find $filter -print0 |  xargs -0 -L1 basename  | awk -F. '{ print $NF }' | sort | uniq

