#!/bin/bash

export PATH=$PATH:~/bin/
export PATH=$PATH:~/bin/local/


. ~/bin/ps1git.bash
. ~/bin/.git-prompt.sh


alias parseMultiLineInsert="sed \'s$),($),\n($g\'"

export BC_ENV_ARGS=~/.bcrc

alias usage='find .  -mindepth 1 -maxdepth 1 -print0 | xargs -0 du -s | sort -n -r -k 1'
alias usageFiilesOnly='find . -maxdepth 3 -type f -print0 | xargs -0 du | sort -nrk 1'

alias mv='mv -i'
alias cp='cp -i'

export PS1="\h $PS1"
export TMOUT=86400
export EDITOR=vim

alias ssh='ssh -XA'

gcd() {
	cd `git rev-parse --show-toplevel`
}

fn='-mutt-clearlyu-medium-r-normal--0-0-100-100-p-0-iso10646-1'
alias alert="xmessage -fn $fn -nearmouse"

echo $DISPLAY > ~/.currentDisplay

(! dropbox running) || dropbox status
