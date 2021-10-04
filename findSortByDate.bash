#!/bin/bash
find . "$@" -printf "%T@ %Tc %p\n" | sort -n
