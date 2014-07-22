#!/bin/bash

char=${2:-'#'}
length=${1:-`tput cols`}

yes "$char" |  head -n $length | tr -d "\n" | xargs echo
