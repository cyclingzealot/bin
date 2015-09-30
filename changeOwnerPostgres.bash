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
__base="$(basename ${__file})"
ts=`date +'%Y%m%d-%H%M%S'`

#Set the config file
configFile="$HOME/.binJlam/templateConfig"

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
pid=`ps -ef | grep ${__base} | grep -v 'vi ' | head -n1 |  awk ' {print $2;} '`
echo ${pid} > ${pidfile}


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

export DISPLAY=:0

echo Begin `date`  .....

echo; echo; echo;

### BEGIN SCRIPT ###############################################################

# From http://stackoverflow.com/questions/1348126/modify-owner-on-all-tables-simultaneously-in-postgresql


database=${1:-}
newOwner=${2:-}
extraArgs=${3-''}

if [[ -z ${database} || -z ${newOwner} ]] ; then 
    echo Usage: $__base '$database $newOwner'
    echo
    exit 1
fi

set -x 
for tbl in `psql $extraArgs -qAt -c "select tableowner,tablename from pg_tables where schemaname = 'public';" $database` ; do  
    table=`echo $tbl | cut -d '|' -f 2`
    owner=`echo $tbl | cut -d '|' -f 1`
    psql $extraArgs -d $database -U $owner -c "alter table \"$table\" owner to $newOwner" $database ;
done

for tbl in `psql $extraArgs -qAt -c "select sequence_name from information_schema.sequences where sequence_schema = 'public';" $database` ; do  
    psql $extraArgs -c "alter table \"$tbl\" owner to $newOwner" $database ; 
done

for tbl in `psql $extraArgs -qAt -c "select table_name from information_schema.views where table_schema = 'public';" $database` ; do  
    psql $extraArgs -c "alter table \"$tbl\" owner to $newOwner" $database ; 
done
set +x

### END SCIPT ##################################################################

END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo; echo; echo;
echo Done.  `date` - $DIFF seconds

if [ -f ${pidfile} ]; then
    rm ${pidfile}
fi
