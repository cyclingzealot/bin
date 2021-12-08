#!/bin/bash


arg1=${1:-''}


usageStr=$(cat << END
Usage: $0 \$stringToSearch | [-t|--time=] [-s|--string=] [-e|--exception=] [-o|--must-run]]

You can either supply no arguments and a string to search OR the following arguments:

    -t|--time=           Seconds to wait between scans
    -s|--string=         String to search
    -e|--exception=      Substring Exception to search. Defaults to 'grep'
    -o|--must-run        Proc must be present to continue

END
)

if [[ $arg1 == '--help' || $arg1 == '-h' ]]; then
    echo "$usageStr"
    exit 0
fi


#exit when command fails (use || true when a command can fail)
#set -o errexit

#exit when your script tries to use undeclared variables
set -o nounset

# in scripts to catch mysqldump fails
#set -o pipefail

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # Dir of the script
__root="$(cd "$(dirname "${__dir}")" && pwd)"           # Dir of the dir of the script
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"       # Full path of the script
__base="$(basename ${__file})"                          # Name of the script
ts=`date +'%Y%m%d-%H%M%S'`
ds=`date +'%Y%m%d'`
pid=`ps -ef | grep ${__base} | grep -v 'vi ' | head -n1 |  awk ' {print $2;} '`
formerDir=`pwd`


numProcs=1
waitSecs=1
exception='grep'
string=''
continueOnPresence='false'

# Wait for
# http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash#answer-14203146

noArgs='false'
if [[ $# -eq 1 ]]; then
    string="$1"
    noArgs='true'
fi


for i in "$@"; do

  case $i in
      -t=*|--time=*)
      waitSecs="${i#*=}"
      shift # past argument
      ;;
      -s=*|--string=*)
      string="${i#*=}"
      shift # past argument
      ;;
      -n=*|--numProcs=*)
      numProcs="${i#*=}"
      shift # past argument
      ;;
      -e=*|--exception=*)
      exception="${i#*=}"
      shift
      ;;
      -o|--must-run)
      continueOnPresence='true'
      shift
      ;;
      *)
      if [[ "$noArgs" == 'false' ]]; then
        echo "Unknown option $i"
        echo
        echo "$usageStr"
        exit 1
      fi
      shift
      ;;
  esac
  shift # past argument or value
done

if [[ -z "$string" ]]; then
    echo Need a non-empty search string
    exit 1
fi

if [[ "$continueOnPresence" == 'true' ]]; then
    echo "Waiting for a process with substring $string to appear"
else
    echo $0 sees:
    ps -ef | grep $string | grep -ve "$exception" | grep -v untilDone
fi


function numProcsMethod {
    numProcs=`ps -ef | grep "$string" | grep -v $exception | grep -v untilDone |  wc -l`
    echo "$numProcs"
}


function shouldKeepWaiting {
    numProcs=$(numProcsMethod)

    keepWaiting='true'

    if [[ "$continueOnPresence" == 'true' ]]; then
        if [[ "$numProcs" -ge 1 ]]; then
            keepWaiting='false'
        fi
    else
        if [[ "$numProcs" -eq 0 ]]; then
            keepWaiting='false'
        fi
    fi

    echo $keepWaiting
}


while [[ $(shouldKeepWaiting) == 'true' ]]; do
    printf . ;
	sleep $waitSecs;
done

echo
