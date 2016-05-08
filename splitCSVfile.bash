#!/usr/bin/env bash

START=$(date +%s.%N)

#exit when command fails (use || true when a command can fail)
set -o errexit

#exit when your script tries to use undeclared variables
set -o nounset

# in scripts to catch mysqldump fails
set -o pipefail

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # Dir of the script
__root="$(cd "$(dirname "${__dir}")" && pwd)"           # Dir of the dir of the script
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"       # Full path of the script
__base="$(basename ${__file})"                          # Name of the script
pid=`ps -ef | grep ${__base} | grep -v 'vi ' | head -n1 |  awk ' {print $2;} '`
ts=`date +'%Y%m%d-%H%M%S'`

#Set the config file
configFile="$HOME/.binJlam/templateConfig"

#Check that the config file exists
#if [[ ! -f "$configFile" ]] ; then
#        echo "I need a file at $configFile with ..."
#        exit 1
#fi

export DISPLAY=:0

echo Begin `date`  .....

echo; echo; echo;

### BEGIN SCRIPT ###############################################################

# Chops a large CSV files into pieces

#(a.k.a set -x) to trace what gets executed
set -o xtrace


original=`basename $1`
numLines=$2

bn=`~/bin/chopSuffix.bash $original`
suffix=`~/bin/suffix.bash $original`

tail -n +2 $original | split -l $numLines - ${bn}_
for file in ${bn}_*
do
    tmpFile=/tmp/$pid.$original.tmp
    head -n 1 $original > $tmpFile
    cat $file >> $tmpFile
    rm $file
    mv -f $tmpFile ./$file.$suffix
done

set +x

### END SCIPT ##################################################################

END=$(date +%s.%N)
DIFF=$(echo "round($END - $START)" | bc)
echo; echo; echo;
echo Done.  `date` - $DIFF seconds
