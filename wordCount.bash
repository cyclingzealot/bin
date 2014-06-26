#!/bin/bash

perl -0777 -lape's/\s+/\n/g' $1 | sort | uniq -c | sort -nr
