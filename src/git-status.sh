#!/usr/bin/env bash

SHOW_NETSPEED=$(tmux show-option -gv @tokyo-night-tmux_show_git)
if [ "$SHOW_NETSPEED" == "0" ]; then
  exit 0
fi

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $CURRENT_DIR/themes.sh
source $CURRENT_DIR/../lib/coreutils-compat.sh

cd "$1" || exit 1
RESET="#[fg=${THEME[foreground]},bg=${THEME[background]},nobold,noitalics,nounderscore,nodim]"
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
STATUS=$(git status --porcelain 2>/dev/null | grep -cE "^(M| M)")
BRANCH_SIZE=${#BRANCH}

SYNC_MODE=0
NEED_PUSH=0

if test "$BRANCH_SIZE" -gt "25"; then
  BRANCH=$(echo "$BRANCH" | cut -c1-25)"…"
fi

STATUS_CHANGED=""
STATUS_INSERTIONS=""
STATUS_DELETIONS=""
STATUS_UNTRACKED=""

if test "$STATUS" != "0"; then
  DIFF_COUNTS=($(git diff --numstat 2>/dev/null | awk 'NF==3 {changed+=1; ins+=$1; del+=$2} END {printf("%d %d %d", changed, ins, del)}'))
  CHANGED_COUNT=${DIFF_COUNTS[0]}
  INSERTIONS_COUNT=${DIFF_COUNTS[1]}
  DELETIONS_COUNT=${DIFF_COUNTS[2]}

  SYNC_MODE=1
fi

STATUS_UNTRACKED="$(git ls-files --other --directory --exclude-standard | wc -l | bc)"

if [[ $CHANGED_COUNT -gt 0 ]]; then
  STATUS_CHANGED="#[fg=${THEME[yellow]},bg=${THEME[background]},bold] ${CHANGED_COUNT} "
fi

if [[ $INSERTIONS_COUNT -gt 0 ]]; then
  STATUS_INSERTIONS="#[fg=${THEME[green]},bg=${THEME[background]},bold] ${INSERTIONS_COUNT} "
fi

if [[ $DELETIONS_COUNT -gt 0 ]]; then
  STATUS_DELETIONS="#[fg=${THEME[red]},bg=${THEME[background]},bold] ${DELETIONS_COUNT} "
fi

if [[ $STATUS_UNTRACKED -gt 0 ]]; then
  STATUS_UNTRACKED="#[fg=#565f89,bg=#15161e,bold] ${STATUS_UNTRACKED} "
else
  STATUS_UNTRACKED=""
fi

# Determine repository sync status
if [[ $SYNC_MODE -eq 0 ]]; then
  NEED_PUSH=$(git log @{push}.. | wc -l | bc)
  if [[ $NEED_PUSH -gt 0 ]]; then
    SYNC_MODE=2
  else
    LAST_FETCH=$(stat -c %Y .git/FETCH_HEAD | bc)
    NOW=$(date +%s | bc)

    # if 5 minutes have passed since the last fetch
    if [[ $((NOW - LAST_FETCH)) -gt 300 ]]; then
      git fetch --atomic origin --negotiation-tip=HEAD
    fi

    REMOTE_DIFF="$(git diff --shortstat "$(git rev-parse --abbrev-ref HEAD)" "origin/$(git rev-parse --abbrev-ref HEAD)" 2>/dev/null | wc -l | bc)"
    if [[ $REMOTE_DIFF -gt 0 ]]; then
      SYNC_MODE=3
    fi
  fi
fi

if [[ $SYNC_MODE -gt 0 ]]; then
  case "$SYNC_MODE" in
  1)
    REMOTE_STATUS="$RESET#[bg=#15161e,fg=#ff9e64,bold]▒ 󱓎"
    ;;
  2)
    REMOTE_STATUS="$RESET#[bg=#15161e,fg=#f7768e,bold]▒ 󰛃"
    ;;
  3)
    REMOTE_STATUS="$RESET#[bg=#15161e,fg=#bb9af7,bold]▒ 󰛀"
    ;;
  *)
    echo default
    ;;
  esac
else
  REMOTE_STATUS="$RESET#[fg=#73daca,bg=#15161e,bold]▒ "
fi

if test "$BRANCH" != ""; then
  if test "$STATUS" = "0"; then
    echo "$REMOTE_STATUS $RESET$BRANCH $RESET$STATUS_UNTRACKED"
  else
    echo "$REMOTE_STATUS $RESET$BRANCH $RESET$STATUS_CHANGED$RESET$STATUS_INSERTIONS$RESET$STATUS_DELETIONS$RESET$STATUS_UNTRACKED"
  fi
fi
