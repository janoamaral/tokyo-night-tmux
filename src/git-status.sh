#!/bin/env bash
cd $1
RESET="#[fg=brightwhite,bg=#15161e,nobold,noitalics,nounderscore,nodim]"
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
STATUS=$(git status --porcelain 2>/dev/null| egrep "^(M| M)" | wc -l)

STATUS_CHANGED=""
STATUS_INSERTIONS=""
STATUS_DELETIONS=""
PR_COUNT=""
REVIEW_COUNT=""
ISSUE_COUNT=""
PR_STATUS=""
REVIEW_STATUS=""
ISSUE_STATUS=""
GH_STATUS=""

if test "$BRANCH" != ""; then
  PR_COUNT=$(gh pr status --json reviewRequests --jq '.needsReview | length' | bc)
  REVIEW_COUNT=$(gh pr status --json reviewRequests --jq '.needsReview | length' | bc)
  ISSUE_COUNT=$(gh issue status --json assignees --jq '.assigned | length' | bc)
fi

if test "$STATUS" != "0"; then
  CHANGED_COUNT=$(git diff --shortstat 2>/dev/null | tr "," "\n" | grep "chang" | cut -d" " -f2 | bc)
  INSERTIONS_COUNT="$(git diff --shortstat 2>/dev/null | tr "," "\n" | grep "ins" | cut -d" " -f2 | bc)"
  DELETIONS_COUNT="$(git diff --shortstat 2>/dev/null | tr "," "\n" | grep "del" | cut -d" " -f2 | bc)"
fi

if [[ $CHANGED_COUNT > 0 ]]; then
  STATUS_CHANGED="#[fg=#e0af68,bg=#15161e,bold] ${CHANGED_COUNT} "
fi

if [[ $INSERTIONS_COUNT > 0 ]]; then
  STATUS_INSERTIONS="#[fg=#44dfaf,bg=#15161e,bold] ${INSERTIONS_COUNT} "
fi

if [[ $DELETIONS_COUNT > 0 ]]; then
  STATUS_DELETIONS="#[fg=#f7768e,bg=#15161e,bold] ${DELETIONS_COUNT} "
fi

if [[ $PR_COUNT > 0 ]]; then
  PR_STATUS="#[fg=#3fb950,bg=#15161e,bold] ${RESET}${PR_COUNT} "
fi

if [[ $REVIEW_COUNT > 0 ]]; then
  REVIEW_STATUS="#[fg=#e0af68,bg=#15161e,bold] ${RESET}${REVIEW_COUNT} "
fi

if [[ $ISSUE_COUNT > 0 ]]; then
  ISSUE_STATUS="#[fg=#3fb950,bg=#15161e,bold] ${RESET}${ISSUE_COUNT} "
fi

GH_STATUS="#[fg=#464646,bg=#15161e,bold]🮐 $RESET#[fg=#fafafa]  $RESET$PR_STATUS$REVIEW_STATUS$ISSUE_STATUS"
GL_STATUS="$RESET "

if test "$BRANCH" != ""; then
  if test "$STATUS" = "0"; then
    echo "#[fg=#44dfaf,bg=#15161e,bold]🮐  $RESET$BRANCH $GH_STATUS"
  else
    echo "#[fg=#ff1178,bg=#15161e,bold]🮐  $RESET$BRANCH $RESET$STATUS_CHANGED$RESET$STATUS_INSERTIONS$RESET$STATUS_DELETIONS$GH_STATUS"
  fi
fi
