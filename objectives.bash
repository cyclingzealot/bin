#!/usr/bin/env bash

START=$(date +%s.%N)

confDir="$HOME/.objectives/"
mkdir -p $confDir

#Check that the config file exists
arg1=${1:-''}

if [[ $arg1 == '--help' || $arg1 == '-h' ]]; then
    echo "Looks in $confDir for weekley and monthly objectives"
    echo "To be specific, files named weekley and monthly"
    echo "If the content is 'none', it will skip and not bother you about it"
    echo "Today's week number and month number must match the file's modification date, or it will bug you to renew"
    exit 0
fi

#Set the config file
configFile="$HOME/.binJlam/$0"

#if [[ ! -f "$configFile" ]] ; then
#        echo "I need a file at $configFile with ..."
#        exit 1
#fi


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


export DISPLAY=:0


### BEGIN SCRIPT ###############################################################

#(a.k.a set -x) to trace what gets executed
#set -o xtrace




for period in weekly monthly weekend ; do
    today_criteria=-1
    file_mtime_criteria=-2

    crieria='0'


    case $period in
        weekly)
            criteria='%Y%W'
            ;;
        monthly)
            criteria='%Y%m'
            ;;
        weekend)

            criteria='%Y%W'
            ;;
        *)
            echo "Unknown period $period"
            exit 1
            ;;
    esac


    msg_file=$confDir/$period.txt
    today_criteria=$(date +"$criteria")

    if [ ! -f "$msg_file" ] ;  then
        echo "Error: File $msg_file is missing"
        continue
    elif grep -e "^none$" $msg_file ; then
        continue
    fi

    file_mtime_criteria=$(date +"$criteria" -r $msg_file)

    if [ "$today_criteria" -ne "$file_mtime_criteria" ] ; then
        echo "Erreur: Met à jour ton but $period avec   vi $msg_file"
        continue
    fi

    if [ "$period" == 'weekend' ] && [ $(date +'%u') -lt 6 ]; then
        continue
    fi

    headline.bash $period = 36
    cat $msg_file
    echo
done



set +x

### END SCIPT ##################################################################

cd $formerDir

END=$(date +%s.%N)
DIFF=$(echo "($END - $START)" | bc | cut -f 1 -d. )

