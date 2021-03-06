#!/usr/bin/env bash

#exit when command fails (use || true when a command can fail)
set -o errexit

#exit when your script tries to use undeclared variables
set -o nounset

#(a.k.a set -x) to trace what gets executed
set -o xtrace

# in scripts to catch mysqldump fails 
set -o pipefail

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"


#Capture everything to log
log=~/log/$__base.log
exec >  >(tee -a $log)
exec 2> >(tee -a $log >&2)

export DISPLAY=:0

/usr/bin/notify-send `date +'%Y/%m/%d %H:%M:%S'`
