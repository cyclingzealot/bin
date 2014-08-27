#!/bin/bash
git branch -d `git branch --merged | grep -v master`
