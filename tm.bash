#!/bin/bash

clear
echo `date +'%H:%M'`  $@
figlet -W -w `tput cols` `date +'%H:%M'` $'\n' "$@"
