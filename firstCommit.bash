#!/bin/bash

git rev-list --max-parents=0 HEAD | tr -d '\n'

