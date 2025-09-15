#!/usr/bin/env bash

START=$(date +%s.%N)

arg1=${1:-''}

if [[ $arg1 == '--help' || $arg1 == '-h' ]]; then
    echo "Usage: $0 [\$loadThreshold]"
    exit 0
fi

#exit when command fails (use || true when a command can fail)
set -o errexit

#exit when your script tries to use undeclared variables
set -o nounset

# in scripts to catch mysqldump fails
set -o pipefail

# Resolve first directory of script
PRG="$BASH_SOURCE"
progname=`basename "$BASH_SOURCE"`

while [ -h "$PRG" ] ; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '/.*' > /dev/null; then
        PRG="$link"
    else
        PRG=`dirname "$PRG"`"/$link"
    fi
done

__dir=$(dirname "$PRG")


# Set magic variables for current file & dir
__root="$(cd "$(dirname "${__dir}")" && pwd)"           # Dir of the dir of the script
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"       # Full path of the script
__base="$(basename ${__file})"                          # Name of the script
ts=`date +'%Y%m%d-%H%M%S'`
ds=`date +'%Y%m%d'`
pid=`ps -ef | grep ${__base} | grep -v 'vi ' | head -n1 |  awk ' {print $2;} '`
formerDir=`pwd`

# If you require named arguments, see
# http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

#Set the config file
configFile="$HOME/.binJlam/$0.conf"

#=== BEGIN Unique instance ============================================
#Ensure only one copy is running
pidfile=$HOME/.${__base}.pid
if [ -f ${pidfile} ]; then
   #verify if the process is actually still running under this pid
   oldpid=`cat ${pidfile}`
   result=`ps -ef | grep ${oldpid} | grep ${__base} || true`

   if [ -n "${result}" ]; then
     echo "Script already running! Exiting"
     exit 255
   fi
fi

#grab pid of this process and update the pid file with it
echo ${pid} > ${pidfile}

# Create trap for lock file in case it fails
trap "rm -f $pidfile" INT QUIT TERM ERR
#=== END Unique instance ============================================


#Capture everything to log
mkdir -p ~/log
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

export DISPLAY=:0

echo Begin `date`  .....

echo; echo; echo;

### BEGIN SCRIPT ###############################################################

#(a.k.a set -x) to trace what gets executed
#set -o xtrace


echo "Getting sudo clearance so you don't have to watch this script output"
sudo -l > /dev/null

echo -n Waiting on connection before upgrade....
while ! ping -W 5 -c 1 -q ca.archive.ubuntu.com > /dev/null 2>&1 ; do
    echo -n .
    sleep 1
done

echo
echo Got connection.
echo


function updateList {
    sudo nice -n 19 apt-get upgrade --just-print | grep Inst | cut -f 2 -d ' ' | sort  > /tmp/upgradePackageList.txt
    wc -l /tmp/upgradePackageList.txt | cut -f 1 -d ' '
}

echo Upgrade per-language package managers
ls /usr/local/bin/composer && sudo /usr/local/bin/composer self-update
# which npm && sudo npm install -g npm
which rvm && rvm get head


# Now upgrade system
echo Check to see if apt is running
untilDone.bash apt-get

waitTH=${1:-2}
sudo -l > /dev/null
echo Waiting until the load is below $waitTH
~/bin/loadBelowCheck.bash -v -r -t=$waitTH
sudo nice -n 19 apt-get update


set -x
numPacks=$(updateList)
continueFlag=/tmp/continueUpgrade
touch $continueFlag

while [ $numPacks -gt 0 ] && [ -a $continueFlag ] ; do
	i="0"

	for pack in `cat /tmp/upgradePackageList.txt | head -n 20 ` ; do
		i=`echo "$i + 1" | bc`
		pct=`echo "$i * 100 / $numPacks" | bc`


		echo "$pack ($i of $numPacks - $pct %)"
		echo ===== To stop =======\> rm $continueFlag
	    # Ideally, loadBelowCheck should be after sudo
	    set -x
		if [ -a $continueFlag ] ; then ~/bin/loadBelowCheck.bash -v -r -t=$waitTH; sudo nice -n 19 apt-get install $pack --only-upgrade --yes  -d; fi
		if [ -a $continueFlag ] ; then ~/bin/loadBelowCheck.bash -v -r -t=$waitTH; sudo nice -n 19 apt-get install $pack --only-upgrade --yes ;  fi
		echo; echo; echo
	done

    numPacks=$(updateList)
done

if [ -a $continueFlag ] ; then sudo nice -n 19 apt-get autoremove ;  fi

echo
rm -v $continueFlag;


set +x

### END SCIPT ##################################################################

cd $formerDir

END=$(date +%s.%N)
DIFF=$(echo "($END - $START)" | bc | cut -f 1 -d. )
echo; echo; echo;
echo Done.  `date` - $DIFF seconds

#=== BEGIN Unique instance ============================================
if [ -f ${pidfile} ]; then
    rm ${pidfile}
fi
#=== END Unique instance ============================================
