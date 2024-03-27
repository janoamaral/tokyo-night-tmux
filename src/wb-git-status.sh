#!/usr/bin/env bash

cd $1
RESET="#[fg=brightwhite,bg=#15161e,nobold,noitalics,nounderscore,nodim,nostrikethrough]"
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
PROVIDER=$(git config remote.origin.url | awk -F '@|:' '{print $2}')
STATUS=$(git status --porcelain 2>/dev/null| egrep "^(M| M)" | wc -l)

PROVIDER_ICON=""

PR_COUNT=0
REVIEW_COUNT=0
ISSUE_COUNT=0
REMOTE_DIFF=0

PR_STATUS=""
REVIEW_STATUS=""
ISSUE_STATUS=""
REMOTE_STATUS=""

if [[ $PROVIDER == "github.com" ]]; then

  if ! command -v gh &> /dev/null; then
    exit 1
  fi

  PROVIDER_ICON="$RESET#[fg=#fafafa] "
  if test "$BRANCH" != ""; then
    PR_COUNT=$(gh pr list --json number --jq 'length' | bc)
    REVIEW_COUNT=$(gh pr status --json reviewRequests --jq '.needsReview | length' | bc)
    ISSUE_COUNT=$(gh issue status --json assignees --jq '.assigned | length' | bc)
  else
    exit 0
  fi
else
  PROVIDER_ICON="$RESET#[fg=#fc6d26] "
  if test "$BRANCH" != ""; then
    PR_COUNT=$(glab mr list | grep -E "^\!" | wc -l | bc)
    REVIEW_COUNT=$(glab mr list --reviewer=@me | grep -E "^\!" | wc -l | bc)
    ISSUE_COUNT=$(glab issue list | grep -E "^\#" | wc -l | bc)
  else
    exit 0
  fi
fi

if test "$STATUS" = "0"; then
  #git fetch --atomic origin --negotiation-tip=HEAD
  #REMOTE_DIFF="$(git diff --shortstat $(git rev-parse --abbrev-ref HEAD) origin/$(git rev-parse --abbrev-ref HEAD) 2>/dev/null | wc -l | bc)"
  REMOTE_DIFF="$(git diff --quiet @{u} && echo "0" || echo "1")"
else
  # We know there are changes, so we don't need to check for remote diff
  REMOTE_DIFF=1
fi

if [[ $PR_COUNT > 0 ]]; then
  PR_STATUS="#[fg=#3fb950,bg=#15161e,bold] ${RESET}${PR_COUNT} "
fi

if [[ $REVIEW_COUNT > 0 ]]; then
  REVIEW_STATUS="#[fg=#d29922,bg=#15161e,bold] ${RESET}${REVIEW_COUNT} "
fi

if [[ $ISSUE_COUNT > 0 ]]; then
  ISSUE_STATUS="#[fg=#3fb950,bg=#15161e,bold] ${RESET}${ISSUE_COUNT} "
fi

if [[ $REMOTE_DIFF > 0 ]]; then
  # REMOTE_STATUS="$RESET#[fg=#f7768e,bold]󰾕 "
  REMOTE_STATUS="$RESET#[fg=#0f0f14,bg=#f7768e,bold] 󰓦 "
else
  REMOTE_STATUS="$RESET#[fg=#c0caf5,bg=#3D59A1,bold]  "
fi

if [[ $PR_COUNT > 0 || $REVIEW_COUNT > 0 || $ISSUE_COUNT > 0 ]]; then
  WB_STATUS="#[fg=$REMOTE_STATUS$RESET $PROVIDER_ICON $RESET$PR_STATUS$REVIEW_STATUS$ISSUE_STATUS"
fi

echo "$WB_STATUS"

# Wait extra time if status-interval is less than 30 seconds to
# avoid to overload GitHub API
INTERVAL="$(tmux show -g | grep status-interval | cut -d" " -f2 | bc)"
if [[ $INTERVAL < 20 ]]; then
  sleep 20
fi
