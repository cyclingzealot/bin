#!/usr/bin/env bash

START=$(date +%s.%N)

arg1=${1:-''}

if [[ $arg1 == '--help' ]] || [[ $arg1 == '-h' ]] || [[ -z "$arg1" ]]; then
	echo "Usage: $0 -d|--database=\$database -t|--timeout=\$timeoutInSeconds -s|--storage=\$pathToMountPointOrDir [-b|--minBytes=\$number]"
    echo "Runs vaccum full on all tables until the vacuum full has reached the designated amount of time"
    echo "Will run on increasingly big tables"
    echo
    echo "-d|--database 	The database to log into"
    echo "-t|--timeout		The max number of seconds to run for an VACUUM FULL command"
    echo "-s|--storage 		The path to your storage device or directory.  $0 will not run analyze full on more than this.   WARNING NOT IMPLEMENTED IF IT MISSED SOME"
    echo "-b|--minBytes		Optional. Minimum number of table bytes for table to be considered on analyze. Defaults to 1"
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

database=''
timeout=''
minBytes=1

for i in "$@"
do
case $i in
    -d=*|--database=*)
    database="${i#*=}"
    shift # past argument=value
    ;;
    -t=*|--timeout=*)
    timeout="${i#*=}"
    shift # past argument=value
    ;;
    -b=*|--minBytes=*)
    minBytes="${i#*=}"
    shift # past argument=value
    ;;
    -s=*|--storage=*)
    storage="${i#*=}"
    shift # past argument=value
    ;;
    *)
          # unknown option
	  echo "Unkown option $i. Did you include = ? It must be included."
	  exit 1
    ;;
esac
done


if [ -z "$timeout" ]; then
	echo "Timeout argument (-t=) in seconds is required.  How many seconds for a single ANALYZE FULL max run."
	exit 1
fi

if [ -z "$database" ]; then
	echo "Database argument (-d=) is required. What database do you want to log into."
	exit 1
fi

if [ -z "$storage" ]; then
	echo "storage argument (-s=) is required. What dir or mountpoint are your tables stored in?"
	exit 1
fi


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
echo ${pid} > $pidfile



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


maxBytes=$(df -P $storage | awk 'NR==2 {print $4}')

echo "Timeout is ${timeout} seconds"
echo "Database is ${database}"
echo "maxBytes is ${maxBytes}"
echo "minBytes is ${minBytes}"

mkdir -p ~/tmp/
scratchFile=~/tmp/$__base.scratch
touch $scratchFile
chmod 600 $scratchFile



(
psql $database << EOF
SELECT         'VACUUM  FULL VERBOSE ' || table_schema || '.' || TABLE_NAME || ';' vacuum_cmd,
pg_size_pretty(total_bytes) AS total,
total_bytes
      FROM (
      SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes FROM (
          SELECT c.oid,nspname AS table_schema, relname AS TABLE_NAME
              , c.reltuples AS row_estimate
              , pg_total_relation_size(c.oid) AS total_bytes
              , pg_indexes_size(c.oid) AS index_bytes
              , pg_total_relation_size(reltoastrelid) AS toast_bytes
          FROM pg_class c
          LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE relkind = 'r'
      ) a
	where total_bytes BETWEEN $minBytes AND CAST($maxBytes AS BIGINT) * 1024 
    ) a order by total_bytes asc;
EOF
) | grep VACUUM  > $scratchFile || true


echo "Commands to run in..."
wc -l $scratchFile

#set -o xtrace

OLDIFS=$IFS
IFS=$'\n'

for line in `cat $scratchFile`; do
	vacuumCmd=$(echo $line | cut -d'|' -f 1)
	bytes=$(echo $line | cut -d'|' -f 3)
	humanSize=$(echo $line | cut -d'|' -f 2)
	echo
	echo "Will do $vacuumCmd .  Table is $humanSize ($bytes bytes)."
	sleep 1
	cmdBegin=`date +%s`
	psql $database -c "$vacuumCmd"
	now=`date +%s`
	let "cmdElapsed=$now-$cmdBegin" || true	
	echo
	echo $cmdElapsed seconds

	if [ "$cmdElapsed" -ge "$timeout" ]; then
		echo "Command execution was or more than $timeout seconds, exiting"
		break
	fi
done


echo "Done.  There may be more tables than $maxBytes bytes that could not be vacuumed full because of lack of disk space."

IFS=$OLDIFS
set +x


### END SCIPT ##################################################################

cd $formerDir

END=$(date +%s.%N)
DIFF=$(echo "($END - $START)" | bc | cut -f 1 -d. )
echo; echo; echo;
echo Done.  `date` - $DIFF seconds

#=== BEGIN Unique instance ============================================
set -x
if [ -f $pidfile ]; then
    rm $pidfile
fi
#=== END Unique instance ============================================
