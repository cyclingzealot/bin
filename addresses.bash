#!/bin/bash

# Works for IPV4

for interface in `ifconfig | grep -o ^[a-z]*` ; do
    addr=`ifconfig $interface | grep -i inet |  grep -i adr | head -n 1 | cut -d ':' -f 2 | cut -d ' ' -f 1`
    printf "%10s: %s\n" $interface $addr
done
