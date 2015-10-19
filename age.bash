#!/bin/bash
# get OLDEST (or NEWEST file age) from the current folder
# spurce http://www.abrandao.com/category/software/code-software/
# if no parameters are specified find the OLdest file in current folder
set -x
if [ $# -eq 0 ]
then
    OLDEST=$(find . -type f | cut -c3- |xargs ls -t | head -1)
    #echo "OLDEST file: $OLDEST"

elif [ -d "$1" ]; then
    cd $1
    OLDEST=$(find . -type f | cut -c3- |xargs ls -t | head -1)
    cd -

else
    OLDEST="$1"
    #echo "File Age for: [$OLDEST]"
fi
#now lets do the date match and get back in seconds (since epoch) time
time_now=`date +%s`
old_filetime=`stat -c %Y $OLDEST`
#new_filetime=`stat -c %Y $NEWEST`
time_oldest=$(( (time_now - old_filetime) ))
UNIT="secs"
#echo "$OLDEST file is $time_oldest $UNIT old"
#convert time to make it more readable in sec/min/hour
if [ $time_oldest -gt 60 ]
then
time_oldest=$((time_oldest/60))
UNIT="min."
if [ $time_oldest -gt 60 ]
then
time_oldest=$((time_oldest/60))
UNIT="hrs"
fi
fi
# Display oldest filename followed by age in sec/min/hour
echo "$OLDEST is $time_oldest $UNIT"
#time_newest=$(( (time_now - new_filetime) ))
#echo "$OLDEST file is $time_oldest $UNIT old"
# echo "$NEWEST file is $time_newest secs. old"
