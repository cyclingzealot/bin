#!/bin/bash

while(true); do
    read file
    cat $file | lynx --stdin
done
