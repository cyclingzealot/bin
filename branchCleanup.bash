#!/bin/bash

### Deletes all branches that have been merged to master and not named 'devServer'


git checkout master &&
git branch -d `git branch --merged | grep -v master | grep -v devServer | grep -v release`
