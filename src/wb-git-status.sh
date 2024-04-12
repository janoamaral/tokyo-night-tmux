#!/usr/bin/env bash
SHOW_WIDGET=$(tmux show-option -gv @tokyo-night-tmux_show_wbg)
if [ "$SHOW_WIDGET" == "0" ]; then
  exit 0
fi

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR../lib/coreutils-compat.sh"
source "$CURRENT_DIR/themes.sh"

cd "$1" || exit 1
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
PROVIDER=$(git config remote.origin.url | awk -F '@|:' '{print $2}')
STATUS=$(git status --porcelain 2>/dev/null | grep -cE "^(M| M)")

PROVIDER_ICON=""

PR_COUNT=0
REVIEW_COUNT=0
ISSUE_COUNT=0
BUG_COUNT=0

PR_STATUS=""
REVIEW_STATUS=""
ISSUE_STATUS=""
BUG_STATUS=""

if [[ $PROVIDER == "github.com" ]]; then

  if ! command -v gh &>/dev/null; then
    exit 1
  fi

  PROVIDER_ICON="$RESET#[fg=${THEME[foreground]}] "
  if test "$BRANCH" != ""; then
    PR_COUNT=$(gh pr list --json number --jq 'length' | bc)
    REVIEW_COUNT=$(gh pr status --json reviewRequests --jq '.needsReview | length' | bc)
    RES=$(gh issue list --json "assignees,labels" --assignee @me)
    ISSUE_COUNT=$(echo $RES | jq 'length' | bc)
    BUG_COUNT=$(echo $RES | jq 'map(select(.labels[].name == "bug")) | length' | bc)
    ISSUE_COUNT=$((ISSUE_COUNT - BUG_COUNT))
  else
    exit 0
  fi
else
  PROVIDER_ICON="$RESET#[fg=#fc6d26] "
  if test "$BRANCH" != ""; then
    PR_COUNT=$(glab mr list | grep -cE "^\!")
    REVIEW_COUNT=$(glab mr list --reviewer=@me | grep -cE "^\!")
    ISSUE_COUNT=$(glab issue list | grep -cE "^\#")
  else
    exit 0
  fi
fi

if [[ $PR_COUNT -gt 0 ]]; then
  PR_STATUS="#[fg=${THEME[ghgreen]},bg=${THEME[background]},bold] ${RESET}${PR_COUNT} "
fi

if [[ $REVIEW_COUNT -gt 0 ]]; then
  REVIEW_STATUS="#[fg=${THEME[ghyellow]},bg=${THEME[background]},bold] ${RESET}${REVIEW_COUNT} "
fi

if [[ $ISSUE_COUNT -gt 0 ]]; then
  ISSUE_STATUS="#[fg=${THEME[ghgreen]},bg=${THEME[background]},bold] ${RESET}${ISSUE_COUNT} "
fi

if [[ $BUG_COUNT -gt 0 ]]; then
  BUG_STATUS="#[fg=${THEME[ghred]},bg=${THEME[background]},bold] ${RESET}${BUG_COUNT} "
fi

if [[ $PR_COUNT -gt 0 || $REVIEW_COUNT -gt 0 || $ISSUE_COUNT -gt 0 ]]; then
  WB_STATUS="#[fg=${THEME[black]},bg=${THEME[background]},bold] $RESET$PROVIDER_ICON $RESET$PR_STATUS$REVIEW_STATUS$ISSUE_STATUS$BUG_STATUS"
fi

echo "$WB_STATUS"

# Wait extra time if status-interval is less than 30 seconds to
# avoid to overload GitHub API
INTERVAL="$(tmux show -g | grep status-interval | cut -d" " -f2 | bc)"
if [[ $INTERVAL -lt 20 ]]; then
  sleep 20
fi
