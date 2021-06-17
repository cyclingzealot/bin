#!/bin/bash

# set -x

# From https://askubuntu.com/a/22257/333952
confirm() {
    echo -n "Do you want to run $*? [N/y] "
    read -N 1 REPLY
    echo
    if test "$REPLY" = "y" -o "$REPLY" = "Y"; then
        "$@"
    else
        echo "Cancelled by user"
    fi
}

export PATH=$PATH:~/bin/
export PATH=$PATH:~/bin/local/
export PATH=$PATH:~/bin/gitTools/


. ~/bin/ps1git.bash
. ~/bin/.git-prompt.sh


alias parseMultiLineInsert="sed \'s$),($),\n($g\'"

export BC_ENV_ARGS=~/.bcrc

alias usage='find .  -mindepth 1 -maxdepth 1 -print0 | xargs -0 du -s | sort -n -r -k 1'
alias usageFiilesOnly='find . -maxdepth 3 -type f -print0 | xargs -0 du | sort -nrk 1'

alias mv='mv -vi'
alias cp='cp -vi'
alias bc='bc -l'

export PS1="\h $PS1"
export TMOUT=43200
export EDITOR=vi

export TERM=xterm-256color   # For tmux & vim compatibilty

gcd() {
	cd `git rev-parse --show-toplevel`
}

gpwd() {
	git rev-parse --show-toplevel | tr -d '\n'
}

# To see git log from all branches.  You can specify a file after
gitChangesAllBranches="git log --all --"  #From https://stackoverflow.com/a/7466798/1611925

# git deploy steps
alias gitDeployStep1_updateMaster='git checkout master && git pull'
alias gitDeployStep2_mergeFromToDeploy='confirm "git merge toDeploy && git push && git checkout release && git pull"'
alias gitDeployStep3_mergeFromMasterAndDeploy="confirm bash -c 'git merge master && git push && rvmDo cap production deploy'"
echo "gitDeploySteps have been set, might want to try them"

fn='-mutt-clearlyu-medium-r-normal--0-0-100-100-p-0-iso10646-1'
alias alert="xmessage -fn $fn -nearmouse"

echo $DISPLAY > ~/.currentDisplay

which dropbox > /dev/null && ((! dropbox running) || dropbox status)

alias newBranch='git checkout --track '
alias clipboard='xsel --clipboard'

flagger.bash timeUntil 60 && ~/bin/timeUntil.bash 100


# For ssh agent fowrading in bash
# From https://gist.github.com/martijnvermaat/8070533#gistcomment-1317075
if [[ -S "$SSH_AUTH_SOCK" && ! -h "$SSH_AUTH_SOCK" ]]; then
    ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock;
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock;

alias firefox-reboot='untilDone.bash firefox; firefox'


PROMPT_COMMAND='echo -en "\033]0; $("hostname")@$("pwd") \a"'

alias battery=acpi

function settitle() {
  if [[ -z "$ORIG" ]]; then
    ORIG=$PS1
  fi
  TITLE="\[\e]2;$*\a\]"
  PS1=${ORIG}${TITLE}
}
alias set-title=settitle


set -x
function railsConsole() {
    TITLE="\[\e]2;console\a\]"
    PS1=${ORIG}${TITLE}
    bash --login -c 'rvm default do rails c'
}
set +x


case "$-" in
*i*)
    echo -n "Tab name: "
    read tabName
    if [[ ! -z "$tabName" ]]; then settitle $tabName; fi
    ;;
esac

#alias rvmDo='rvm default do'
function rvmDo() {
    if which rvm > /dev/null; then
        rvm default do "$@"
    else
        toRun="$@"
        toRun="rvm default do $toRun"
        bash --login -c "$toRun"
    fi
}
alias rmvDo='echo No rmvDo. I think you meant rvmDo'

#alias findSortByDate='find . -printf "%T@ %Tc %p\n" | sort -n'
#alias findSortBySize='find . -type f  -exec du -h {} + | sort -r -h'

alias filesBySize="find . -type f -ls -printf '\0' | sort -zk7n | tr -d '\0'"

alias railsConsole="bash --login -c 'rvm default do rails c'"

alias dimForNight=redshift

alias removeSpaces="rename -v  -e 's/ /_/g' "
alias renameSpaces=removeSpaces
alias removeSpacesOld="rename -v  's/ /_/g' "

alias whatIsMyIp="wget -q -O - checkip.dyndns.org|sed -e 's/.*Current IP Address: //' -e 's/<.*$//'"

alias dnsReset="sudo /etc/init.d/dns-clean restart; sudo /etc/init.d/networking force-reload"

alias addColumn="paste -sd+ | bc"


echo TMOUT set to `echo $TMOUT/'(60*60)' | bc | cut -d. -f 1` hours


umask 027
echo
echo umask set to `umask`
echo


