#!/bin/sh

ps -ef  | grep xflux | grep grep -v || /home/jlam/bin/xflux -l 45.4096756 -g -75.715057 -k 2000
