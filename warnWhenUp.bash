#!/bin/bash

if [ -z "$1" ]; then
	echo "Please supply a web site to monitor"
	exit 1
fi

while(true); do 
	date
	notice="$1 is up"
	lynx -connect_timeout=2 -dump "$1" && echo && echo $notice && notify-send "$notice" && play -q `ls -rShd /usr/share/sounds/* | tail -n 1`
	echo
	sleep 5
done
