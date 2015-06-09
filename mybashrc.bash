#!/bin/bash

export PATH=$PATH:~/bin/
export PATH=$PATH:~/bin/local/


. ~/bin/ps1git.bash
. ~/bin/.git-prompt.sh


alias parseMultiLineInsert="sed \'s$),($),\n($g\'"

export BC_ENV_ARGS=~/.bcrc

alias usage='find .  -maxdepth 1 -print0 | xargs -0 du -aS | sort -n -r -k 1'
alias usageFiilesOnly='find . -maxdepth 3 -type f -print0 | xargs -0 du | sort -nrk 1'

alias mv='mv -i'
alias cp='cp -i'

export PS1="\h $PS1"

export EDITOR=vim
