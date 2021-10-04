#!/bin/bash

screen -ls
echo
echo Cycling you through them....
sleep 1
for session in `tmux list-sessions | cut -d: -f 1`; do tmux attach -t $session; done
