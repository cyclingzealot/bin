#!/usr/bin/env bash

START=$(date +%s.%N)

arg1=${1:-''}

# Check interval (2 seconds)
CHECK_INTERVAL=2

if [[ $arg1 == '--help' || $arg1 == '-h' ]]; then
    echo "Low Memory Monitor - Displays xmessage alert when free memory drops below 2 GB"
    echo "Runs continuously for 1 hour, checking every ${CHECK_INTERVAL} seconds"
    echo "Usage: $0"
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
set -o xtrace

# Memory threshold in MB (2 GB = 2048 MB)
THRESHOLD_MB=2048

# Duration to run (1 hour = 3600 seconds)
RUN_DURATION=3600

# Calculate end time
SCRIPT_START=$(date +%s)
END_TIME=$((SCRIPT_START + RUN_DURATION))

echo "Starting memory monitor. Will run until $(date -d @${END_TIME})"
echo "Threshold: ${THRESHOLD_MB} MB"
echo "Check interval: ${CHECK_INTERVAL} seconds"

# Track if we've already shown an alert
ALERT_SHOWN=0
ALERT_COOLDOWN=300  # Don't show another alert for 5 minutes
LAST_ALERT_TIME=0

while true; do
    CURRENT_TIME=$(date +%s)

    # Check if we've exceeded our run duration
    if [ $CURRENT_TIME -ge $END_TIME ]; then
        echo "Reached 1 hour runtime limit. Exiting to allow fresh start."
        break
    fi

    # Get available memory in MB
    AVAILABLE_MB=$(free -m | awk '/^Mem:/ {print $7}')

    echo "$(date): Available memory: ${AVAILABLE_MB} MB"

    # Check if available memory is below threshold
    if [ "$AVAILABLE_MB" -lt "$THRESHOLD_MB" ]; then
        TIME_SINCE_LAST_ALERT=$((CURRENT_TIME - LAST_ALERT_TIME))

        # Only show alert if cooldown period has passed
        if [ $TIME_SINCE_LAST_ALERT -ge $ALERT_COOLDOWN ]; then
            echo "WARNING: Low memory detected! Showing alert."

            # Display warning message
            xmessage -center -timeout 30 \
                "WARNING: Low Memory!\n\nAvailable Memory: ${AVAILABLE_MB} MB\nThreshold: ${THRESHOLD_MB} MB\n\nPlease close some applications." &

            LAST_ALERT_TIME=$CURRENT_TIME
            ALERT_SHOWN=1
        else
            echo "Alert cooldown active. ${TIME_SINCE_LAST_ALERT}/${ALERT_COOLDOWN} seconds"
        fi
    fi

    # Sleep for check interval
    sleep $CHECK_INTERVAL
done

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
