#!/usr/bin/env bash

cd $1
RESET="#[fg=brightwhite,bg=#15161e,nobold,noitalics,nounderscore,nodim]"
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
STATUS=$(git status --porcelain 2>/dev/null| egrep "^(M| M)" | wc -l)
BRANCH_SIZE=${#BRANCH}

SYNC_MODE=0
NEED_PUSH=0
NEED_PULL=0

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

  SYNC_MODE=1
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

# Determine repository sync status
if [[ $SYNC_MODE == 0 ]]; then
    NEED_PUSH=$(git log @{push}.. | wc -l | bc)
    if [[ $NEED_PUSH > 0 ]]; then
      SYNC_MODE=2
    else
      LAST_FETCH=$(stat -c %Y .git/FETCH_HEAD | bc)
      NOW=$(date +%s | bc)

      # if 5 minutes have passed since the last fetch
      if [[ $((NOW-LAST_FETCH)) -gt 300 ]]; then
        git fetch --atomic origin --negotiation-tip=HEAD
      fi

      REMOTE_DIFF="$(git diff --shortstat $(git rev-parse --abbrev-ref HEAD) origin/$(git rev-parse --abbrev-ref HEAD) 2>/dev/null | wc -l | bc)"
      if [[ $REMOTE_DIFF > 0 ]]; then
        SYNC_MODE=3
      fi
    fi
fi

if [[ $SYNC_MODE > 0 ]]; then
    case "$SYNC_MODE" in
      1) REMOTE_STATUS="$RESET#[bg=#15161e,fg=#ff9e64,bold]▒ 󱓎"
      ;;
      2) REMOTE_STATUS="$RESET#[bg=#15161e,fg=#f7768e,bold]▒ 󰛶"
      ;;
      3) REMOTE_STATUS="$RESET#[bg=#15161e,fg=#bb9af7,bold]▒ 󰛴"
      ;;
      *) echo default
      ;;
    esac
  else
    REMOTE_STATUS="$RESET#[fg=#73daca,bg=#15161e,bold]▒ "
fi

if test "$BRANCH" != ""; then
  if test "$STATUS" = "0"; then
    echo "$REMOTE_STATUS $RESET$BRANCH "
  else
    echo "$REMOTE_STATUS $RESET$BRANCH $RESET$STATUS_CHANGED$RESET$STATUS_INSERTIONS$RESET$STATUS_DELETIONS"
  fi
fi
