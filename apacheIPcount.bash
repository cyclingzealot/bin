#!/usr/bin/env bash

START=$(date +%s.%N)

arg1=${1:-''}

if [[ $arg1 == '--help' || $arg1 == '-h' ]]; then
    echo "$0 pathToAccessLog [threshold] (default 500)"
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

apacheLogPath=$1
threshold=${2:-500}
#POSITIONAL=()
#while [[ $# -gt 0 ]]
#do
#key="$1"
#
#case $key in
#    -a|--accessLog)
#    apacheLogPath="$2"
#    shift # past argument
#    shift # past value
#    ;;
#    -t|--threshold)
#    threshold="$2"
#    shift # past argument
#    shift # past value
#    ;;
#    *)    # unknown option
#    POSITIONAL+=("$1") # save it in an array for later
#    shift # past argument
#    ;;
#esac
#done
#set -- "${POSITIONAL[@]}" # restore positional parameters

#Set the config file
configFile="$HOME/.binJlam/templateConfig"

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

# Credit: https://encodable.com/tech/blog/2008/12/17/Count_IP_Addresses_in_Access_Log_File_BASH_OneLiner

FILE="$apacheLogPath"
 for ip in `cat $FILE |cut -d ' ' -f 1 |sort |uniq`;
 do { COUNT=`grep ^$ip $FILE |wc -l`;
 if [[ "$COUNT" -gt "$threshold" ]]; then echo "$COUNT :   $ip";
 fi }; done | sort -n -k 1 

set +x

### END SCIPT ##################################################################

cd $formerDir

END=$(date +%s.%N)
DIFF=$(echo "round($END - $START)" )
echo; echo; echo;
echo Done.  `date` - $DIFF seconds

#=== BEGIN Unique instance ============================================
if [ -f ${pidfile} ]; then
    rm ${pidfile}
fi
#=== END Unique instance ============================================
