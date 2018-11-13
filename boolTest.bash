#!/bin/bash

falseBool=false
trueBool=true

if ! $falseBool; then
    echo "falseBool is false"
fi

if $trueBool; then
    echo "trueBool is true"
fi
