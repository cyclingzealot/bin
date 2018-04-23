#!/bin/bash

echo -n Waiting on connection before upgrade....
while ! ping -W 5 -c 1 -q www.credil.org > /dev/null 2>&1 ; do
    echo -n .
    sleep 1
done

echo
echo Got connection.
echo


# Upgrade per-language package manager
ls /usr/local/bin/composer && sudo /usr/local/bin/composer self-update
which npm && sudo npm install -g npm
which rvm && rvm get head


# Now upgrade system
# Check to see if apt is running
untilDone.bash apt-get
# Wait until the load is below 2
~/bin/loadBelowCheck.bash -r -t=1
sudo nice -n 19 apt-get update
sudo nice -n 19 apt-get upgrade --just-print | grep Inst | cut -f 2 -d ' ' | sort  > /tmp/upgradePackageList.txt

numPacks=`wc -l /tmp/upgradePackageList.txt | cut -f 1 -d ' '`

continueFlag=/tmp/continueUpgrade
i="0"

touch $continueFlag
for pack in `cat /tmp/upgradePackageList.txt` ; do
	i=`echo "$i + 1" | bc`
	pct=`echo "$i * 100 / $numPacks" | bc`


	echo "$pack ($i of $numPacks - $pct %)"
	echo ===== To stop =======\> rm $continueFlag
    # Ideally, loadBelowCheck should be after sudo
    set -x
	if [ -a $continueFlag ] ; then ~/bin/loadBelowCheck.bash -r -t=2; sudo nice -n 19 apt-get install $pack --only-upgrade --yes  -d; fi
	if [ -a $continueFlag ] ; then ~/bin/loadBelowCheck.bash -r -t=2; sudo nice -n 19 apt-get install $pack --only-upgrade --yes ;  fi
	echo; echo; echo
done

	if [ -a $continueFlag ] ; then sudo nice -n 19 apt-get autoremove ;  fi

echo
rm -v $continueFlag;
