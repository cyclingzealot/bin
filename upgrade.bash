#!/bin/bash

echo "Getting sudo clearance so you don't have to watch this script output"
sudo -l > /dev/null

echo -n Waiting on connection before upgrade....
while ! ping -W 5 -c 1 -q ca.archive.ubuntu.com > /dev/null 2>&1 ; do
    echo -n .
    sleep 1
done

echo
echo Got connection.
echo


function updateList {
    sudo nice -n 19 apt-get upgrade --just-print | grep Inst | cut -f 2 -d ' ' | sort  > /tmp/upgradePackageList.txt
    wc -l /tmp/upgradePackageList.txt | cut -f 1 -d ' '
}

echo Upgrade per-language package managers
ls /usr/local/bin/composer && sudo /usr/local/bin/composer self-update
which npm && sudo npm install -g npm
which rvm && rvm get head


# Now upgrade system
echo Check to see if apt is running
untilDone.bash apt-get

waitTH=${1:-2}
sudo -l > /dev/null
echo Waiting until the load is below $waitTH
~/bin/loadBelowCheck.bash -v -r -t=$waitTH
sudo nice -n 19 apt-get update


set -x
numPacks=$(updateList)
continueFlag=/tmp/continueUpgrade
touch $continueFlag

while [ $numPacks -gt 0 ] && [ -a $continueFlag ] ; do
	i="0"

	for pack in `cat /tmp/upgradePackageList.txt | head -n 20 ` ; do
		i=`echo "$i + 1" | bc`
		pct=`echo "$i * 100 / $numPacks" | bc`


		echo "$pack ($i of $numPacks - $pct %)"
		echo ===== To stop =======\> rm $continueFlag
	    # Ideally, loadBelowCheck should be after sudo
	    set -x
		if [ -a $continueFlag ] ; then ~/bin/loadBelowCheck.bash -v -r -t=$waitTH; sudo nice -n 19 apt-get install $pack --only-upgrade --yes  -d; fi
		if [ -a $continueFlag ] ; then ~/bin/loadBelowCheck.bash -v -r -t=$waitTH; sudo nice -n 19 apt-get install $pack --only-upgrade --yes ;  fi
		echo; echo; echo
	done

    numPacks=$(updateList)
done

if [ -a $continueFlag ] ; then sudo nice -n 19 apt-get autoremove ;  fi

echo
rm -v $continueFlag;
