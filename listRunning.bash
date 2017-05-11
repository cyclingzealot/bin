#!/bin/bash

sudo service --status-all 2>/dev/null| grep -F '+'
initctl list | grep start
