#!/usr/bin/env bash

START=$(date +%s.%N)

#exit when command fails (use || true when a command can fail)
set -o errexit

#exit when your script tries to use undeclared variables
set -o nounset

#(a.k.a set -x) to trace what gets executed
#set -x 

# in scripts to catch mysqldump fails 
set -o pipefail

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
ts=`date +'%Y%m%d-%H%M%S'`

#Set the config file
configFile="$HOME/.checkDomain_domainList"



#Capture everything to log
log=~/log/$__base-${ts}.log
exec >  >(tee -a $log)
exec 2> >(tee -a $log >&2)
touch $log
chmod 600 $log


#Check that the config file exists
if [ ! -f $configFile ] ; then
        echo "I need a file at $configFile with a domain list on one line seperated by spaces and no new line" 
	DOM="theos.in cricketnow.in nixcraft.com nixcraft.org nixcraft.biz nixcraft.net nixcraft.info cyberciti.biz cyberciti.org gite.in nixcraft.in"
	echo
	echo "Like:"
	echo $DOM
	echo
	ls -l $configFile
        exit 1
fi


echo Begin `date`  .....

### BEGIN SCRIPT ###############################################################


# Author 
# Vivek Gite - http://www.cyberciti.biz/tips/howto-monitor-domain-expiration-renew-date.html

workFile=/tmp/${__base}.workfile

# Domain name list - add your domainname here
numDomains=`wc -l $configFile | cut -d ' ' -f 1`
i=1
rm $workFile; touch $workFile
echo Collecting data....
for d in `sort $configFile`
do
  echo "$i of $numDomains: $d..."
  echo $d ' - ' `whois $d | egrep -i 'Expiry|Expiration|Expires on' | head -1` >> $workFile || true 
  # If you need list..
  # whois $d | egrep -i 'Expiry|Expiration|Expires on' | head -1 >> /tmp/domain.date
  #
  let i++
  sleep 1 
done 

echo; echo ;
cat $workFile | while read line; do longdate="$(echo "$line" | rev | cut -f1 -d" " | rev)"; longdateepoch="$(date -d $longdate +%s)"; echo "$longdateepoch $line"; done | sort | cut -d ' ' -f 2-
echo; echo ;

#
# [ -f /tmp/domain.date ] && mail -s 'Domain renew / expiration date' you@yahoo.com < /tmp/domain.date || :
#


### END SCIPT ##################################################################

END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo Done.  `date` - $DIFF seconds
