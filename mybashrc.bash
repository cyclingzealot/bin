#!/bin/bash

export PATH=$PATH:~/bin/


. ~/bin/ps1git.bash
. ~/bin/.git-prompt.sh


export HOSTNAME=`hostname` # HOSTNAME not set some machines
if [ -x /usr/bin/keychain -a -f $HOME/.keychain/${HOSTNAME}-sh ] ; then
/usr/bin/keychain --quiet --nogui $HOME/.ssh/id_cityOttawaGitHub
source $HOME/.keychain/${HOSTNAME}-sh
fi

alias parseMultiLineInsert='sed \'s$),($),\n($g\''
