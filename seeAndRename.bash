#!/usr/bin/env bash

arg1=${1:-''}

__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"       # Full path of the script
__base="$(basename ${__file})"                          # Name of the script

if [[ $arg1 == '--help' || $arg1 == '-h' || -z "$arg1" ]]; then
    echo "Need to provide file name. Usage: $__base \$listOfFiles. Can be a bash file wildcards."
    echo "Ex: $__base *.jpg"
    exit 0
fi

#exit when command fails (use || true when a command can fail)
set -o errexit

#exit when your script tries to use undeclared variables
set -o nounset

# in scripts to catch mysqldump fails
set -o pipefail

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # Dir of the script
__root="$(cd "$(dirname "${__dir}")" && pwd)"           # Dir of the dir of the script
ts=`date +'%Y%m%d-%H%M%S'`
ds=`date +'%Y%m%d'`
pid=`ps -ef | grep ${__base} | grep -v 'vi ' | head -n1 |  awk ' {print $2;} '`
formerDir=`pwd`

# If you require named arguments, see
# http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

export DISPLAY=:0

echo Begin `date`  .....

echo; echo; echo;

### BEGIN SCRIPT ###############################################################

#(a.k.a set -x) to trace what gets executed
set -o xtrace

OIFS="$IFS"
IFS=$'\n'


for file in "$@" ; do
    app=''
    suffix=${file: -4}
    if [[ "$suffix" == ".jpg" || "$suffix" == ".png" || "$suffix" == ".gif" ]]; then
        app=`which eog || which xviewer`
        $app $file
    elif [ "$suffix" == ".pdf" ]; then
        app=`which evince`
        $app $file
    elif [ "$suffix" == ".mp4" ]; then
        app=`which vlc`
        $app $file
    else
        echo "Don't khow how to open $file"
    fi

    if [[ ! -z "$app" ]] ; then
        echo Look at the picture then close...
        untilDone.bash "$app"
        read -p "Move $file to ? " newFileName
        newFileName=${newFileName:-$file}
        if [ "$newFileName" != "$file" ]; then
            mv -vi $file $newFileName || true
        fi
    fi
done


IFS="$OIFS"


set +x

### END SCIPT ##################################################################

cd $formerDir
