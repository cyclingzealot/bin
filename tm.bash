#!/bin/bash

figlet -W -w `tput cols` `date +'%H:%M'` $@;
