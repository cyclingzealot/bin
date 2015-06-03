#!/usr/bin/env bash

#Usage, assuming a *nix box (Mac or Linux):
#
# * place the above in ~/bin/gen_pot.sh and make it executable
# * make sure that ~/bin is in your $PATH
# * in wp-content/themes, run gen_pot.sh yourtheme
# * or from within in your theme's dir, run gen_pot.sh
# * it'll output the pot file automatically...

START=$(date +%s.%N)

#Set the config file
configFile='~/.binJlam/templateConfig'

#exit when command fails (use || true when a command can fail)
set -o errexit

#exit when your script tries to use undeclared variables
#set -o nounset

#(a.k.a set -x) to trace what gets executed
########set -o xtrace

# in scripts to catch mysqldump fails 
set -o pipefail

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
ts=`date +'%Y%m%d-%H%M%S'`


#Capture everything to log
log=~/log/$__base-${ts}.log
exec >  >(tee -a $log)
exec 2> >(tee -a $log >&2)


#Check that the config file exists
#if [[ ! -f "$configFile" ]] ; then
#        echo "I need a file at $configFile with ..."
#        exit 1
#fi


echo Begin `date`  .....

### BEGIN SCRIPT ###############################################################


#!/bin/sh
#
# Author: Peter Eisentraut http://peter.eisentraut.org/
# From: http://stackoverflow.com/questions/5938869/how-to-generate-a-new-pot-template-from-a-translated-po-file#answer-6571977
#

poFile=$1
potFile=`echo $poFile | cut -d '.' -f -1`.pot

set -x 
msgfilter -i $1 -o $potFile true
set +x



### END SCIPT ##################################################################

END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo Done.  `date` - $DIFF seconds
