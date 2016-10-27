#!/bin/bash

figlet -W -w `tput cols` `date +'%H:%M'` $@;
sleep 1
screenshot.bash
