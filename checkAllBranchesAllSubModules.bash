#!/bin/bash 

git-branch-status.bash; 
git submodule foreach --recursive git-branch-status.bash;  

