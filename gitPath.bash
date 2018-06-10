#!/bin/bash

arg1=${1:-''}

if [[ $arg1 == '--help' || $arg1 == '-h' ]]; then
    echo "Provides the path of the current dir or the specified file"
    echo "$0 [\$file]"
    exit 0
fi



gitRoot=`git rev-parse --show-toplevel`
gitRootLength=`echo $gitRoot | wc -c`
gitBaseName=`basename $gitRoot`

extraPath=${1:-''}

if ! ls $extraPath  > /dev/null 2>&1 ; then
    >&2 echo "Pas de fichier $extraPath"
    extraPath=''
fi

if [[ $extraPath == /* ]]; then
    echo -n $gitBaseName`echo "$extraPath" | cut -c $gitRootLength-`
else
    echo -n "$gitBaseName`echo $PWD/ | cut -c $gitRootLength-`"$extraPath
fi
