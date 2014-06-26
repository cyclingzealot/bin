#!/bin/bash

char=${1:-'x'}

yes "$char" |  head -n `tput cols` | tr -d "\n" | xargs echo
