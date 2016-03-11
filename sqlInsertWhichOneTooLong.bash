#!/bin/bash

#exit when command fails (use || true when a command can fail)
set -o errexit

#exit when your script tries to use undeclared variables
set -o nounset

# in scripts to catch mysqldump fails
set -o pipefail

insertsFile=/tmp/inserts.txt
valuesFile=/tmp/values.txt
tableDesc=/tmp/tableDesc.txt
columnDesc=/tmp/columnDesc.txt
final=/tmp/final.txt


touch $insertsFile $valuesFile $tableDesc $columnDesc $insertsFile.perline.txt $valuesFile.perline.txt $final
chmod 600 $insertsFile $valuesFile $tableDesc $columnDesc $insertsFile.perline.txt $valuesFile.perline.txt $final

function reuseFile {
    filePath=$1
    pasteInsructions=$2

    reuseFile=1

    if [ -f $filePath ]; then
        echo
        read -p "Re-use existing $filePath ?" choice
        echo    # (optional) move to a new line

        case "$choice" in
          y|Y ) reuseFile=1;;
          n|N ) ruuseFile=0;;
          * ) reuseFile=1;;
        esac
    else
        reuseFile=0
    fi

    if [ "$reuseFile" -eq 0 ]; then
        echo $pasteInstructions
        cat  > $tableDesc
    else
        echo Content of $filePath is
        cat $filePath | head -n 30
    fi

    echo
}


### Input for column names from insert statement
reuseFile $insertsFile 'Paste the column names.  The whole string between the first set of parathensis.  Paste, then Crtl-D'

### Input for values names from insert statement
reuseFile $valuesFile 'Paste the values.  The whole string between the second set of parathensis.  Paste, then Crtl-D'



### Now for table description
reuseFile $tableDesc "Paste table description now, no column headers or seperation line"

### Transform insert statement to one per line
cat $insertsFile | tr ',' '\n' | tr -d '"' | tr -d ' ' > $insertsFile.perline.txt

chmod 600 $insertsFile.perline.txt

cat $valuesFile | tr ',' '\n' | tr -d ' ' | while read line ; do  echo -n $line ; echo -n ': ' ; echo $line | wc -c ; done > $valuesFile.perline.txt

chmod 600 $valuesFile.perline.txt





### For each  column in insertsFile, grep for tehm in $tableDesc and store them

echo -n "" > $columnDesc
IFS=$'\n'; for column in `cat $insertsFile.perline.txt` ; do
    grep " $column " $tableDesc | cut -d '|' -f 2 | tr -d ' ' >> $columnDesc || true
done


paste -d '|' $insertsFile.perline.txt $valuesFile.perline.txt $columnDesc > $final


cat $final

printf "\n\n\n"

wc -l $insertsFile.perline.txt $valuesFile.perline.txt $columnDesc $final
