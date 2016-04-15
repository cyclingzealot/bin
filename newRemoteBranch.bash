#!/bin/bash


## Yeah, I know git fetch, git checkout should suffice with git > 1.6.6 , but I just feel better doing it this way.

git checkout -b $1 origin/$1
