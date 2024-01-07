#!/bin/env bash
cd $1
RESET="#[fg=brightwhite,bg=#15161e,nobold,noitalics,nounderscore,nodim]"
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
STATUS=$(git status --porcelain 2>/dev/null| egrep "^(M| M)" | wc -l)
BRANCH_SIZE=${#BRANCH}

if test "$BRANCH_SIZE" -gt "25"; then
  BRANCH=$(echo $BRANCH | cut -c1-25)"…"
fi

STATUS_CHANGED=""
STATUS_INSERTIONS=""
STATUS_DELETIONS=""

if test "$STATUS" != "0"; then
  CHANGED_COUNT=$(git diff --shortstat 2>/dev/null | tr "," "\n" | grep "chang" | cut -d" " -f2 | bc)
  INSERTIONS_COUNT="$(git diff --shortstat 2>/dev/null | tr "," "\n" | grep "ins" | cut -d" " -f2 | bc)"
  DELETIONS_COUNT="$(git diff --shortstat 2>/dev/null | tr "," "\n" | grep "del" | cut -d" " -f2 | bc)"
fi

if [[ $CHANGED_COUNT > 0 ]]; then
  STATUS_CHANGED="#[fg=#e0af68,bg=#15161e,bold] ${CHANGED_COUNT} "
fi

if [[ $INSERTIONS_COUNT > 0 ]]; then
  STATUS_INSERTIONS="#[fg=#73daca,bg=#15161e,bold] ${INSERTIONS_COUNT} "
fi

if [[ $DELETIONS_COUNT > 0 ]]; then
  STATUS_DELETIONS="#[fg=#f7768e,bg=#15161e,bold] ${DELETIONS_COUNT} "
fi

if test "$BRANCH" != ""; then
  if test "$STATUS" = "0"; then
    echo "#[fg=#73daca,bg=#15161e,bold]🮐  $RESET$BRANCH "
  else
    echo "#[fg=#f7768e,bg=#15161e,bold]🮐  $RESET$BRANCH $RESET$STATUS_CHANGED$RESET$STATUS_INSERTIONS$RESET$STATUS_DELETIONS"
  fi
fi
