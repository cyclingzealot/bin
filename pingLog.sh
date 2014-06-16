#!/bin/sh

ping -W 5 -c 1 208.67.222.222 > /dev/null 2>&1 && echo `date +'%Y/%m/%d-%H:%M'` 'Success' || echo `date +'%Y/%m/%d-%H:%M'` 'Fail' 
