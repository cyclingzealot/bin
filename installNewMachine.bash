#!/usr/bin/env bash

START=$(date +%s.%N)

#Set the config file
configFile='~/.binJlam/packageList'

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


#Capture everything to log
log=~/log/$__base-${ts}.log
exec >  >(tee -a $log)
exec 2> >(tee -a $log >&2)


#Check that the config file exists
if [[ ! -f "$configFile" ]] ; then
        echo "I need a file at $configFile with ..."
        exit 1
fi


echo Begin `date`  .....

### BEGIN SCRIPT ###############################################################


numPacks=`wc -l $configFile | cut -f 1 -d ' '`

continueFlag=/tmp/continueInstallNewMachine
i="0"

touch $continueFlag
for pack in `cat /tmp/$configFile` ; do 
	i=`echo "$i + 1" | bc`
	pct=`echo "$i * 100 / $numPacks" | bc`


	echo "$pack ($i of $numPacks - $pct %)"
	echo ===== To stop =======\> rm $continueFlag
	if [ -a $continueFlag ] ; then sudo apt-get install $pack --only-upgrade --yes  -d; fi
	if [ -a $continueFlag ] ; then sudo apt-get install $pack --only-upgrade --yes ;  fi
	sleep 1
	echo; echo; echo 
done

	if [ -a $continueFlag ] ; then sudo apt-get autoremove ;  fi

echo 
rm -v $continueFlag;


### END SCIPT ##################################################################

END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo Done.  `date` - $DIFF seconds
#!/bin/bash

