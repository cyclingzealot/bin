#!/bin/bash

file=$1
python -c "import json; fd=open(\"$file\"); answer = json.dumps(json.load(fd), indent=4); print(answer)"
