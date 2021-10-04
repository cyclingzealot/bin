#!/bin/bash

function set-title {
  if [[ -z "$ORIG" ]]; then
    ORIG=$PS1
  fi
  TITLE="\[\e]2;$*\a\]"
  PS1=${ORIG}${TITLE}
}

echo You must run this preceeded with a dot, if you have not alreadyo
type settitle

settitle $1
