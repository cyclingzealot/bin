#!/bin/bash

cat $1 | sort | uniq -c | sort -nr
