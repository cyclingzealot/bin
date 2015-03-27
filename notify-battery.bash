#!/bin/bash

export DISPLAY=:0.0
notify-send "Pile à `acpi | cut -d ' ' -f 4 | sed -n 's/,$//p'`"
