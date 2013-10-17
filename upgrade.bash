#!/bin/bash

sudo /usr/local/bin/composer self-update
sudo apt-get update
sudo apt-get upgrade --just-print | grep Inst | cut -f 2 -d ' ' | sort  > /tmp/upgradePackageList.txt

continueFlag=/tmp/continueUpgrade
touch $continueFlag
for pack in `cat /tmp/upgradePackageList.txt` ; do 
	echo $pack
	echo ===== To stop =======\> rm $continueFlag
	if [ -a $continueFlag ] ; then sudo apt-get install $pack --only-upgrade --yes  -d; fi
	if [ -a $continueFlag ] ; then sudo apt-get install $pack --only-upgrade --yes ;  fi
	echo 
done

echo 
rm -v $continueFlag;
