#!/usr/bin/env bash

START=$(date +%s.%N)

#exit when command fails (use || true when a command can fail)
set -o errexit

#exit when your script tries to use undeclared variables
set -o nounset

#(a.k.a set -x) to trace what gets executed
#set -o xtrace

# in scripts to catch mysqldump fails 
set -o pipefail

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
ts=`date +'%Y%m%d-%H%M%S'`

#Set the config file
configFile="$HOME/.fold.config.bash"


#Capture everything to log
log=~/log/$__base-${ts}.log
exec >  >(tee -a $log)
exec 2> >(tee -a $log >&2)
touch $log
chmod 600 $log


#Check that the config file exists
if [ ! -f "$configFile" ]; then
        echo "I need a file at $configFile with one line with the default width, no line feed or carraige return"
        exit 1
fi


#echo Begin `date`  .....

### BEGIN SCRIPT ###############################################################

scratchFile=/tmp/fold-$ts.txt
touch $scratchFile
chmod 600 $scratchFile

widthDefault=`cat $configFile`

prefix=${1:-}
width=${2:-$widthDefault}


char='='
length=`tput cols`
yes "$char" |  head -n $length | tr -d "\n" | xargs echo || true

echo Input your text then Crtl-D
cat > $scratchFile

yes "$char" |  head -n $width | tr -d "\n" | xargs echo || true

if [ ! -z "$prefix" ] ; then
    let width=$width-2
    fold -w $width -s $scratchFile | sed -e "s/^/$prefix /"
else 
    fold -w $width -s $scratchFile 
fi


rm $scratchFile

yes "$char" |  head -n $width | tr -d "\n" | xargs echo || true

### END SCIPT ##################################################################

#END=$(date +%s.%N)
#DIFF=$(echo "$END - $START" | bc)
#echo Done.  `date` - $DIFF seconds
