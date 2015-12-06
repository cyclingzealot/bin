#!/bin/bash

screen -ls 
echo
echo Cycling you through them.... 
sleep 1
for session in `screen -ls | grep Detached | cut -f 2`; do screen -r $session; done
