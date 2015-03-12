#!/bin/bash

dpkg --get-selections | grep -v deinstall
