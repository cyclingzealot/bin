#!/bin/bash

echo Cutting $1
ID=`echo $1 | cut -d '=' -f 2 | cut -d '&' -f 1`

echo Opening "http://www.youtube.com/v/${ID}?fs=1&amp;hl=fr_FR"
epiphany-browser http://www.youtube.com/v/${ID}?fs=1\&amp\;hl=fr_FR\&autoplay=1\&loop=1

