#!/bin/sh

while (true); do
    echo; echo; echo ;
    date;
    ping credil.org -i 1 -c 5 $1;
    sleep 1
done
