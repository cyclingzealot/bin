#!/bin/bash

sep=${1:-''}

date +"%Y$sep%m$sep%d" | tr -d '\n'
