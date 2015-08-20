#!/bin/bash

find . -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "

# As per http://stackoverflow.com/questions/4561895/how-to-recursively-find-the-latest-modified-file-in-a-directory
