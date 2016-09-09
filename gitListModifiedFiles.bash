#!/bin/bash

git status | grep modified  | awk '{print $3}' | rev | cut -d/ -f 1 | rev | tr $'\n' ' '
