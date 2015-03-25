#!/usr/bin/env bash

#Usage, assuming a *nix box (Mac or Linux):
#
# * place the above in ~/bin/gen_pot.sh and make it executable
# * make sure that ~/bin is in your $PATH
# * in wp-content/themes, run gen_pot.sh yourtheme
# * or from within in your theme's dir, run gen_pot.sh
# * it'll output the pot file automatically...

START=$(date +%s.%N)

#Set the config file
configFile='~/.binJlam/templateConfig'

#exit when command fails (use || true when a command can fail)
set -o errexit

#exit when your script tries to use undeclared variables
set -o nounset

#(a.k.a set -x) to trace what gets executed
#set -o xtrace

# in scripts to catch mysqldump fails 
set -o pipefail

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
ts=`date +'%Y%m%d-%H%M%S'`


#Capture everything to log
log=~/log/$__base-${ts}.log
exec >  >(tee -a $log)
exec 2> >(tee -a $log >&2)


#Check that the config file exists
#if [[ ! -f "$configFile" ]] ; then
#        echo "I need a file at $configFile with ..."
#        exit 1
#fi


echo Begin `date`  .....

### BEGIN SCRIPT ###############################################################


#!/bin/sh
#
# Author: Denis de Bernardy <http://www.mesoconcepts.com>
# Version: 0.1
# GPL licensed
# From: http://wordpress.stackexchange.com/questions/3555/how-do-i-add-a-new-string-to-a-po-or-pot-file#answer-3557
#
# Created by Ryan Boren
# Later code and patches from
# Kimmo Suominen (more) and Nikolay Bachiyski (less)
# Denis de Bernardy





cwd=`pwd`

if [ -n "$1" ];
then
    cd "$1" || exit 1
    slug=`basename $1`
    dir=$cwd/$slug
else
    dir=$cwd
    slug=`basename $cwd`
fi

pot_file=$slug.pot

cp /dev/null "$dir/$pot_file"

find . -name '*.php' -print \
| sed -e 's,^\./,,' \
| sort \
| xargs xgettext \
    --keyword=__ \
    --keyword=_e \
    --keyword=_c \
    --keyword=__ngettext:1,2 \
    --keyword=_n:1,2 \
    --default-domain=$slug \
    --language=php \
    --output="$dir/$pot_file" \
    --join-existing \
    --from-code utf-8 \
    --copyright-holder='Mesoconcepts <http://www.mesoconcepts.com>' \
    --msgid-bugs-address=https://tickets.semiologic.com

# sub only the YEAR in the copyright message (the 2nd line)
sed -i '' -e '2s/YEAR/'`date +%Y`'/' "$pot_file"

# and the cherry of the pie - extract version using magic - versoextracanus!~

if [ -f $dir/style.css ];
then
    name=`fgrep -i 'Theme Name:' $dir/style.css`
    version=`fgrep -i 'Version:' $dir/style.css`
elif [ -f $dir/$slug.php ];
then
    #statements
    name=`fgrep -i 'Plugin Name:' $dir/$slug.php`
    version=`fgrep -i 'Version:' $dir/$slug.php`
else
    name=$slug
    version=
fi

name=${name##*:}
name=${name##[[:space:]]}
version=${version##*:}
version=${version##[[:space:]]}
version=${version%%[[:space:]]*}

if [ "$name" != '' ];
then
    sed -i '' -e "1s/^# SOME DESCRIPTIVE TITLE/# $name pot file/" "$pot_file"
    sed -i '' -e "s/\(^#.*\)PACKAGE\(.*\)/\1$name\2/g" "$pot_file"
fi

if [ "$version" != '' ];
then
    sed -i '' -e "s/\(Project-Id-Version: \)PACKAGE VERSION/\1$version/" "$pot_file"
fi

cd "$cwd"

### END SCIPT ##################################################################

END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo Done.  `date` - $DIFF seconds
