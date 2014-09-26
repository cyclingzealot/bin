#!/bin/sh


lockfile="/tmp/clearFlashFile.lock"
if [ -z "$flock" ] ; then
  lockopts="-w 0 $lockfile"
  exec env flock=1 flock $lockopts $0 "$@"
fi

while(true); do
	find /tmp -name 'Flash*' -mmin +60 -exec rm -vf {} \;
	sleep 3600
done;


