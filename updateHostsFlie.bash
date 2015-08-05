#!/usr/bin/env bash

START=$(date +%s.%N)

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
ts=`date +'%Y%m%d-%H%M%S'`

#Set the config file
configFile="$HOME/.binJlam/templateConfig"


#Capture everything to log
log=~/log/$__base-${ts}.log
exec >  >(tee -a $log)
exec 2> >(tee -a $log >&2)
touch $log
chmod 600 $log


#Check that the config file exists
#if [[ ! -f "$configFile" ]] ; then
#        echo "I need a file at $configFile with ..."
#        exit 1
#fi


echo Begin `date`  .....

### BEGIN SCRIPT ###############################################################

tmpFileStore=/tmp/winHelpHostsFile.txt
marker='### BAD HOSTS BEGIN'
hostsFile=/etc/hosts
baseFile=/tmp/hosts.base


curl http://winhelp2002.mvps.org/hosts.txt | dos2unix > $tmpFileStore

sleep 1

wc -l $tmpFileStore

sleep 1
sudo cp -v $hostsFile $hostsFile.bak
sleep 1

lineNumber=`grep -n "$marker" $hostsFile | cut -d ':' -f 1 || true`
sleep 1

if [[ ! -z "$lineNumber" ]]; then 
	let lineNumber--
	sleep 1
	head -n $lineNumber $hostsFile > $baseFile 
else 
	cp $hostsFile $baseFile
fi
sleep 1

wc -l $baseFile


echo >> $baseFile
echo >> $baseFile
echo >> $baseFile
echo >> $baseFile
echo "$marker" >> $baseFile
cat $tmpFileStore >> $baseFile

wc -l $baseFile

/usr/bin/less -M -N $baseFile

sudo cp -i $baseFile $hostsFile

#rm -v $baseFile $tmpFileStore



### END SCIPT ##################################################################

END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo Done.  `date` - $DIFF seconds
