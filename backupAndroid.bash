#!/bin/sh


BACKUPDIR=~/backups/n1Backup/
TARFILE="$BACKUPDIR/n1Backup.`date +'%Y%m%d-%H%M'`.tar"
VOLUMENAME="3413-180E"



cd /media/

mkdir $BACKUPDIR

begin=`date +'%s'`

set -x 
size=`du -sk $VOLUMENAME | cut -f 1`
tar -cO $VOLUMENAME --exclude="$VOLUMENAME/Musique/*"  --show-omitted-dirs --exclude="$VOLUMENAME/acast/*.mp3" --exclude="*thumbnail*" --exclude="*cache*" --exclude="$VOLUMENAME/php-manual/*"  | pv -ep -s ${size}k > $TARFILE
set +x

echo Checking tar file integrity
tar -tf $TARFILE > /dev/null

if [ "$?" -eq 0 ]; then

xterm -e 'echo Taper mot de passe pour démonter; ~/bin/demonterAndroid' &

echo Begin compressing of tar file `date` ...
gzip -v9 $TARFILE

echo Deleting older files
find ~/backups/n1Backup/*.tar* -mtime +180  -exec rm -v {} \;

end=`date +'%s'`

elapsed=`echo "($end - $begin)/60" | bc`

echo $elapsed minutes elapsed

ls -lrth $BACKUPDIR

echo Checking tar file integrity
gzip -dc $TARFILE.gz | tar -t > /dev/null && echo Looks good.

echo

fi
