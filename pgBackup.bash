#!/usr/bin/env bash

START=$(date +%s.%N)

arg1=${1:-''}


if [[ $arg1 == '--help' || $arg1 == '-h' || -z "$arg1" ]]; then
    echo
    echo "$0 \$dbName [\$backupDir]" 
    echo
    echo "Script defaults to ~/backups/\$dbName as your backupDir"
    echo "\$backupDir should be a full path should you choose to specify it and will override defaults"
    echo
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
configFile="$HOME/.binJlam/templateConfig"

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

function needScript {
	echo I ${2:-need} a script called $1 at ~/bin/$1 
	echo Download it at https://raw.githubusercontent.com/cyclingzealot/bin/master/$1
	echo "This should do it:"
	echo "curl https://raw.githubusercontent.com/cyclingzealot/bin/master/trimFolder.bash > ~/bin/$1" 
	echo "chmod 700 ~/bin/$1"
	echo 
}

#(a.k.a set -x) to trace what gets executed
#set -o xtrace

dbName=$1
backupDir=${2:-~/backups/$dbName/}
mkdir -p $backupDir
backupSetDir=$backupDir/$dbName.`hostname`.$ts/
mkdir -p $backupSetDir

if ! ls ~/bin/headline.bash > /dev/null ; then
	needScript 'headline.bash'
	exit 1
fi


### GLOBALS ####################################################################
~/bin/headline.bash 'Globals'

target=$backupSetDir/$dbName.globals.`hostname`.$ts.sql

set -x 
pg_dumpall -g > $target
set +x
echo

echo Compressing backup file....
gzip -9v $target

echo 

echo DONE: Backup of globals.  Your globals backup is at
ls -lh $target*

echo

echo "NOTE: Backups will include --clean --if-exists instructions, which drops database objects before creating them"

sleep 5


### MAIN BACKUP ################################################################
~/bin/headline.bash 'Main backup'


target=$backupSetDir/$dbName.data.`hostname`.$ts.sql

touch $target

echo
set -x 
pg_dump --clean --if-exists $dbName >> $target
set +x
echo

echo Compressing backup file....
gzip -9v $target

echo 

echo "DONE: Backup of data.  Your data backup is at"
ls -lh $target*
sleep 2


echo

### TRIM AND SET RO ############################################################
if ! ls ~/bin/trimFolder.bash > /dev/null ; then
	echo 'To trim backups'
	needScript 'trimFolder.bash' 'couse use'
else
	~/bin/headline.bash 'Trimming backups folder'
	~/bin/trimFolder.bash  $backupDir 1024 'gz'
fi

~/bin/headline.bash 'Making sure backups are read only. Tail -n 5 output of chmod -v:'
chmod 700 -vR $backupDir | tail -n 5


set +x

### END SCIPT ##################################################################

cd $formerDir

END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo; echo; echo;
echo Done.  `date` - $DIFF seconds

#=== BEGIN Unique instance ============================================
if [ -f ${pidfile} ]; then
    rm ${pidfile}
fi
#=== END Unique instance ============================================
