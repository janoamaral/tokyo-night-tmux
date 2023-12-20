#!/bin/env bash
cd $1
RESET="#[fg=brightwhite,bg=#15161e,nobold,noitalics,nounderscore,nodim]"
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
STATUS=$(git status --porcelain 2>/dev/null| egrep "^(M| M)" | wc -l)

STATUS_CHANGED=""
STATUS_INSERTIONS=""
STATUS_DELETIONS=""
STATUS_REMOTE=""

if test "$STATUS" != "0"; then
  CHANGED_COUNT=$(git diff --shortstat 2>/dev/null | tr "," "\n" | grep "chang" | cut -d" " -f2 | bc)
  INSERTIONS_COUNT="$(git diff --shortstat 2>/dev/null | tr "," "\n" | grep "ins" | cut -d" " -f2 | bc)"
  DELETIONS_COUNT="$(git diff --shortstat 2>/dev/null | tr "," "\n" | grep "del" | cut -d" " -f2 | bc)"
fi

REMOTE_STATUS=$(git fetch --dry-run --negotiation-tip=$(git rev-parse --abbrev-ref HEAD) --negotiate-only | wc -l | bc)

if [[ $CHANGED_COUNT > 0 ]]; then
  STATUS_CHANGED="#[fg=#e0af68,bg=#15161e,bold] ${CHANGED_COUNT} "
fi

if [[ $INSERTIONS_COUNT > 0 ]]; then
  STATUS_INSERTIONS="#[fg=#44dfaf,bg=#15161e,bold] ${INSERTIONS_COUNT} "
fi

if [[ $DELETIONS_COUNT > 0 ]]; then
  STATUS_DELETIONS="#[fg=#f7768e,bg=#15161e,bold] ${DELETIONS_COUNT} "
fi

if [[ $REMOTE_STATUS > 0 ]]; then
  STATUS_REMOTE="󱓎"
else
  STATUS_REMOTE=""
fi

if test "$BRANCH" != ""; then
  if test "$STATUS" = "0"; then
    echo "#[fg=#44dfaf,bg=#15161e,bold]🮐 $STATUS_REMOTE $RESET$BRANCH "
  else
    echo "#[fg=#ff1178,bg=#15161e,bold]🮐 $STATUS_REMOTE $RESET$BRANCH $RESET$STATUS_CHANGED$RESET$STATUS_INSERTIONS$RESET$STATUS_DELETIONS"
  fi
fi
