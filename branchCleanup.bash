#!/bin/bash
git checkout master &&
git branch -d `git branch --merged | grep -v master`
