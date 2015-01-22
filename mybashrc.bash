#!/bin/bash

export PATH=$PATH:~/bin/
export PATH=$PATH:~/bin/local/


. ~/bin/ps1git.bash
. ~/bin/.git-prompt.sh


export HOSTNAME=`hostname` # HOSTNAME not set some machines
if [ -x /usr/bin/keychain -a -f $HOME/.keychain/${HOSTNAME}-sh ] ; then
/usr/bin/keychain --quiet --nogui $HOME/.ssh/id_cityOttawaGitHub
source $HOME/.keychain/${HOSTNAME}-sh
fi

alias parseMultiLineInsert="sed \'s$),($),\n($g\'"

export BC_ENV_ARGS=~/.bcrc

alias usage='find . -maxdepth 1 -print0 | xargs -0 du -s | sort -n -r -k 1'
alias usageFiilesOnly='find . -maxdepth 3 -type f -print0 | xargs -0 du | sort -nrk 1'

alias mv='mv -i'
alias cp='cp -i'

export PS1="\h $PS1"
