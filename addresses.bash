#!/bin/bash

# Prioritizes ipv4.
for interface in `ifconfig | grep -o ^[a-z]*` ; do
    addr=`ifconfig $interface | grep -i inet |  grep 'adr\|addr' | head -n 1 | cut -d ':' -f 2 | cut -d ' ' -f 1`

    if [ -z "$addr" ]; then  # Try IPv6
        addr=`ifconfig $interface | grep -i inet |  grep 'adr\|addr' | head -n 1 | cut -d ':' -f 2- | cut -d ' ' -f 2`
    fi

    printf "%10s: %s\n" $interface $addr
done
