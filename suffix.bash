#!/bin/bash

echo $1  | rev | cut -d '.' -f 1 | rev | tr -d '\n'
