#!/bin/bash

# Returns 0 if the git status is clean, non zero if not

[[ `git status` =~ "working directory clean" ]]
