#!/bin/bash 
cd /etc/ssh
for file in *sa_key.pub
do   ssh-keygen -lf $file
done
