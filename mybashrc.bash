#!/bin/bash

export PATH=$PATH:~/bin/
export PATH=$PATH:~/bin/local/
export PATH=$PATH:~/bin/gitTools/


. ~/bin/ps1git.bash
. ~/bin/.git-prompt.sh


alias parseMultiLineInsert="sed \'s$),($),\n($g\'"

export BC_ENV_ARGS=~/.bcrc

alias usage='find .  -mindepth 1 -maxdepth 1 -print0 | xargs -0 du -s | sort -n -r -k 1'
alias usageFiilesOnly='find . -maxdepth 3 -type f -print0 | xargs -0 du | sort -nrk 1'

alias mv='mv -i'
alias cp='cp -i'

export PS1="\h $PS1"
export TMOUT=22100
export EDITOR=vi

gcd() {
	cd `git rev-parse --show-toplevel`
}

gpwd() {
	git rev-parse --show-toplevel | tr -d '\n'
}

fn='-mutt-clearlyu-medium-r-normal--0-0-100-100-p-0-iso10646-1'
alias alert="xmessage -fn $fn -nearmouse"

echo $DISPLAY > ~/.currentDisplay

which dropbox > /dev/null && ((! dropbox running) || dropbox status)

alias newBranch='git checkout --track '
alias clipboard='xsel --clipboard'

~/bin/daysOfGiftLeft.bash


# For ssh agent fowrading in bash
# From https://gist.github.com/martijnvermaat/8070533#gistcomment-1317075
if [[ -S "$SSH_AUTH_SOCK" && ! -h "$SSH_AUTH_SOCK" ]]; then
    ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock;
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock;

alias firefox-reboot='untilDone.bash firefox; firefox'

PROMPT_COMMAND='echo -en "\033]0; $("hostname")@$("pwd") \a"'
