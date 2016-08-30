#!/bin/bash

watch "figlet -W -w `tput cols` `date +'%H:%M'` \"$@\"";
