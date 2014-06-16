#!/bin/sh


BACKUPDIR=~/backups/n1Backup/
TARFILE="$BACKUPDIR/n1Backup.`date +'%Y%m%d-%H%M'`.tar"
VOLUMENAME="sftp en tant que root sur 10.0.0.103/sdcard/"



set +x

cd ; cd .gvfs;

mkdir $BACKUPDIR

begin=`date +'%s'`


tar -cf $TARFILE "$VOLUMENAME"  --exclude="$VOLUMENAME/Musique/" --verbose --show-omitted-dirs --exclude='*thumbnail*' --exclude='*cache*' --exclude="$VOLUMENAME/php-manual/" --exclude="$VOLUMENAME/acast/"

gzip -v9 $TARFILE

echo Deleting older files
find $BACKUPDIR/* -mtime +30  -exec rm -v {} \;

end=`date +'%s'`

elapsed=`echo "($begin - $end)/60" | bc`

echo $elapsed minutes elapsed

ls -lSh $BACKUPDIR


