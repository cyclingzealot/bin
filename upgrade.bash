#!/bin/bash

sudo /usr/local/bin/composer self-update
sudo apt-get update
sudo apt-get upgrade --just-print | grep Inst | cut -f 2 -d ' ' | sort  > /tmp/upgradePackageList.txt

numPacks=`wc -l /tmp/upgradePackageList.txt | cut -f 1 -d ' '`

continueFlag=/tmp/continueUpgrade
i="0"

touch $continueFlag
for pack in `cat /tmp/upgradePackageList.txt` ; do 
	i=`echo "$i + 1" | bc`
	pct=`echo "$i / $numPacks * 100" | bc`


	echo "$pack ($i of $numPacks - $pct %)"
	set +x
	echo ===== To stop =======\> rm $continueFlag
	if [ -a $continueFlag ] ; then sudo apt-get install $pack --only-upgrade --yes  -d; fi
	if [ -a $continueFlag ] ; then sudo apt-get install $pack --only-upgrade --yes ;  fi
	sleep 1
	echo 
done

	if [ -a $continueFlag ] ; then sudo apt-get autoremove ;  fi

echo 
rm -v $continueFlag;
