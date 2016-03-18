#!/bin/bash

echo $1  | rev | cut -d '.' -f 2- | rev
