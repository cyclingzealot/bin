#!/usr/bin/env bash

START=$(date +%s.%N)

arg1=${1:-''}

if [[ $arg1 == '--help' || $arg1 == '-h' ]]; then
    echo "Script to kill vim/vi processes editing .txt files in a specified folder"
	echo "Usage: ./kill-vim-txt.sh /path/to/folder"
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


# Check if folder argument is provided
if [ $# -eq 0 ]; then
    echo "Error: No folder specified." >&2
    echo "Usage: $0 /path/to/folder" >&2
    exit 1
fi

FOLDER="$1"

# Check if the specified folder exists
if [ ! -d "$FOLDER" ]; then
    echo "Error: Folder '$FOLDER' does not exist." >&2
    exit 1
fi

# Convert to absolute path to avoid issues with relative paths
FOLDER=$(readlink -f "$FOLDER")

echo "Looking for vim/vi processes editing .txt files in: $FOLDER"

# Find all .txt files in the specified folder
txt_files=$(find "$FOLDER" -maxdepth 1 -name "*.txt" -type f)

if [ -z "${txt_files:-}" ]; then
    echo "No .txt files found in $FOLDER"
    exit 0
fi

# Array to store PIDs of processes to kill
pids_to_kill=()

# Look for vim/vi processes editing these .txt files
while IFS= read -r txt_file; do
    # Use ps and grep to find vim/vi processes with this file
    # Look for both vim and vi processes
    vim_pids=$(ps aux | grep -E '(vim|vi)\s' | grep -F "$(basename "$txt_file")" | grep -v grep | awk '{print $2}' || true)

    if [ -n "${vim_pids:-}" ]; then
        while IFS= read -r pid; do
            if [ -n "$pid" ]; then
                pids_to_kill+=("$pid")
                echo "Found vim/vi process (PID: $pid) editing: $(basename "$txt_file")"
            fi
        done <<< "$vim_pids"
    fi
done <<< "$txt_files"

# If no processes found, exit
if [ ${#pids_to_kill[@]} -eq 0 ]; then
    echo "No vim/vi processes found editing .txt files in the specified folder."
    exit 0
fi

echo "Found ${#pids_to_kill[@]} vim/vi process(es) to terminate."

# First attempt: Send SIGTERM (graceful termination)
echo "Sending SIGTERM to processes..."
for pid in "${pids_to_kill[@]}"; do

    # Show the full command line before killing
    cmd_line=$(ps -p "$pid" -o pid,command --no-headers 2>/dev/null | sed 's/^ *//' || echo "$pid <process not found>")
    echo "About to kill: $cmd_line"

    if kill -TERM "$pid" 2>/dev/null; then
        echo "Sent SIGTERM to PID $pid"
    else
        echo "Failed to send SIGTERM to PID $pid (process may have already exited)"
    fi

    echo
done

# Wait a moment for graceful shutdown
sec_wait=1
echo "Waiting ${sec_wait} seconds for graceful shutdown..."
sleep $sec_wait

# Check which processes are still running and force kill them
echo "Checking for remaining processes..."
remaining_pids=()

for pid in "${pids_to_kill[@]}"; do
    if kill -0 "$pid" 2>/dev/null; then
        remaining_pids+=("$pid")
    fi
done

if [ ${#remaining_pids[@]} -gt 0 ]; then
    echo "Force killing ${#remaining_pids[@]} remaining process(es) with SIGKILL..."


    for pid in "${remaining_pids[@]}"; do

        # Show the full command line before force killing
        cmd_line=$(ps -p "$pid" -o pid,command --no-headers 2>/dev/null | sed 's/^ *//' || echo "$pid <process not found>")
        echo "About to force kill: $cmd_line"

        if kill -9 "$pid" 2>/dev/null ; then
            echo "Force killed PID $pid"
        else
            echo "Failed to force kill PID $pid (process may have already exited)"
        fi
        echo
    done
else
    echo "All processes terminated gracefully."
fi

echo "Done."


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
