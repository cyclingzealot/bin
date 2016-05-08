#!/bin/bash

for branch in $(git rev-list --all)
do
  if (git ls-tree -r --name-only $branch | grep --quiet "$1")
  then
     git branch --contains $branch
  fi
done
