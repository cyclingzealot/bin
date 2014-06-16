#!/bin/sh



HOUR=`date +'%I'`

for i in `seq 1 $HOUR`; do
	echo $i
	play /usr/share/sounds/dclock/bell.wav
done;
