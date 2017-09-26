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
untilDone.bash apt-get
sudo apt-get update
sudo apt-get upgrade --just-print | grep Inst | cut -f 2 -d ' ' | sort  > /tmp/upgradePackageList.txt

numPacks=`wc -l /tmp/upgradePackageList.txt | cut -f 1 -d ' '`

continueFlag=/tmp/continueUpgrade
i="0"

touch $continueFlag
for pack in `cat /tmp/upgradePackageList.txt` ; do
	i=`echo "$i + 1" | bc`
	pct=`echo "$i * 100 / $numPacks" | bc`


	echo "$pack ($i of $numPacks - $pct %)"
	echo ===== To stop =======\> rm $continueFlag
	if [ -a $continueFlag ] ; then sudo apt-get install $pack --only-upgrade --yes  -d; fi
	if [ -a $continueFlag ] ; then sudo apt-get install $pack --only-upgrade --yes ;  fi
	echo; echo; echo
done

	if [ -a $continueFlag ] ; then sudo apt-get autoremove ;  fi

echo
rm -v $continueFlag;
