#!/usr/bin/env bash

arg1=${1:-''}

if [[ $arg1 == '--help' || $arg1 == '-h' ]]; then
    echo "Script author should have provided documentation"
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
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"       # Full path of the script
__base="$(basename ${__file})"                          # Name of the script
ts=`date +'%Y%m%d-%H%M%S'`
ds=`date +'%Y%m%d'`
pid=`ps -ef | grep ${__base} | grep -v 'vi ' | head -n1 |  awk ' {print $2;} '`
formerDir=`pwd`

backupDest=~/backups/crontab/
mkdir -p $backupDest
backupFile=$backupDest/$__base-${ts}.backup
touch $backupFile
chmod 600 $backupFile


# If you require named arguments, see
# http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

echo "#Saved on `date`" | tee $backupFile

printf "\n\n\n" | tee -a $backupFile

### BEGIN SCRIPT ###############################################################

crontab -l | tee -a $backupFile

# Remove really old files
cd $backupDest
find $backupDest -mtime +548 -name "$__base-*.backup" -exec rm -v {} \;

# Remove top line in old files that makes them different
find $backupDest -mtime +90 -type f | xargs --no-run-if-empty sed -i 1d

# Remove duplicates
cd $backupDest
fdupes -r -f . | grep -v '^$' | xargs --no-run-if-empty rm -v

### END SCIPT ##################################################################

cd $formerDir
