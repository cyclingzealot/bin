#!/bin/bash

git status | grep -E 'modified\|modifié'  | awk '{print $3}' | rev | cut -d/ -f 1 | rev | tr $'\n' ' '
