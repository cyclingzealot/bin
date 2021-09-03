#!/bin/bash
find . -type f "$@" -exec du -h {} + | sort -r -h
