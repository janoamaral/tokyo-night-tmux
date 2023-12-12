#!/bin/env bash
cd $1
RESET="#[fg=white,bg=black,nobold,noitalics,nounderscore]"
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
STATUS=$(git status --porcelain 2>/dev/null| egrep "^(M| M)" | wc -l)
STATUS_CHANGED="#[fg=yellow,bg=black,bold]  "
STATUS_INSERTIONS="#[fg=green,bg=black,bold] "
STATUS_DELETIONS="#[fg=red,bg=black,bold] "


if test "$STATUS" != "0"; then
  CHANGED_COUNT="$(git diff --shortstat | tr "," "\n" | grep "changed" | cut -d" " -f2)"
  INSERTIONS_COUNT="$(git diff --shortstat | tr "," "\n" | grep "insertions" | cut -d" " -f2)"
  DELETIONS_COUNT="$(git diff --shortstat | tr "," "\n" | grep "deletions" | cut -d" " -f2)"
fi

if [ "$CHANGED_COUNT" > 0 ]; then
  STATUS_CHANGED="${STATUS_CHANGED}${CHANGED_COUNT}"
fi

if [ "$INSERTIONS_COUNT" > 0 ]; then
  STATUS_INSERTIONS="${STATUS_INSERTIONS}${INSERTIONS_COUNT}"
fi

if [ "$DELETIONS_COUNT" > 0 ]; then
  STATUS_DELETIONS="${STATUS_DELETIONS}${DELETIONS_COUNT}"
fi

if test "$BRANCH" != ""; then
  if test "$STATUS" = "0"; then
    echo "#[fg=green,bg=black,bold]🮐  $RESET$BRANCH "
  else
    echo "#[fg=#ff1178,bg=black,bold]🮐  $RESET$BRANCH $RESET$STATUS_CHANGED $RESET$STATUS_INSERTIONS $RESET$STATUS_DELETIONS "
  fi
fi
