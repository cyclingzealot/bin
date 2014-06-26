#!/bin/bash

char=${1:-'#'}

yes "$char" |  head -n `tput cols` | tr -d "\n" | xargs echo
