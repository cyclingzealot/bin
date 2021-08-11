#!/bin/bash


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

# Wait for
# http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash#answer-14203146

if [[ $# -eq 1 ]]; then
    string="$1"
fi

while [[ $# > 1 ]]
do
key="$1"

case $key in
    -t|--time)
    waitSecs="$2"
    shift # past argument
    ;;
    -s|--string)
    string="$2"
    shift # past argument
    ;;
    -n|--numProcs)
    numProcs="$2"
    shift # past argument
    ;;
    -e|--exception)
    exception="$exception\|$2"
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

string="$1"


if [[ -z "$string" ]]; then
    echo Need a non-empty search string
    exit 1
fi

echo $0 sees:
ps -ef | grep $string | grep -ve "$exception" | grep -v untilDone

while [[ "$numProcs" -gt 0 ]]; do


#set -x
numProcs=`ps -ef | grep "$string" | grep -v $exception | grep -v untilDone |  wc -l`

if [[ "$numProcs" -gt 0 ]]; then
	printf . ;
	sleep $waitSecs;
	#echo ;
	#ps -ef | grep $1 ;
	#echo ;
fi


done

echo
