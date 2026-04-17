#!/usr/bin/env bash

# Imports
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
. "${ROOT_DIR}/lib/coreutils-compat.sh"

ACCENT_COLOR="#7aa2f7"
SECONDARY_COLOR="#24283B"
BG_COLOR="#1F2335"
BG_BAR="#15161e"
TIME_COLOR="#414868"

format_timestamp() {
  local total_seconds=${1:-0}
  printf '%02d:%02d' $((total_seconds / 60)) $((total_seconds % 60))
}

if [[ $1 =~ ^[[:digit:]]+$ ]]; then
  MAX_TITLE_WIDTH=$1
else
  MAX_TITLE_WIDTH=$(($(tmux display -p '#{window_width}' 2>/dev/null || echo 120) - 130))
fi

if [[ $MAX_TITLE_WIDTH -lt 10 ]]; then
  MAX_TITLE_WIDTH=10
fi

OUTPUT=""
PLAY_STATE=""
TIME="[--:--]"

if cmus-remote -Q >/dev/null 2>/dev/null; then
  CMUS_STATUS=$(cmus-remote -Q)
  STATUS=$(echo "$CMUS_STATUS" | grep status | head -n 1 | cut -d' ' -f2-)
  ARTIST=$(echo "$CMUS_STATUS" | grep 'tag artist' | head -n 1 | cut -d' ' -f3-)
  TITLE=$(echo "$CMUS_STATUS" | grep 'tag title' | cut -d' ' -f3-)
  DURATION=$(echo "$CMUS_STATUS" | grep 'duration' | cut -d' ' -f2-)
  POSITION=$(echo "$CMUS_STATUS" | grep 'position' | cut -d' ' -f2-)

  if [[ -n "$DURATION" ]] && [[ -n "$POSITION" ]] && [ "$DURATION" -gt 0 ]; then
    TIME="[$(format_timestamp "$POSITION") / $(format_timestamp "$DURATION")]"
  elif [[ -n "$POSITION" ]]; then
    TIME="[$(format_timestamp "$POSITION") / --:--]"
  fi

  if [ -n "$TITLE" ]; then
    if [ "$STATUS" = "playing" ]; then
      PLAY_STATE=""
    else
      PLAY_STATE=""
    fi
    OUTPUT="$PLAY_STATE $TITLE"

    if [ "${#OUTPUT}" -ge "$MAX_TITLE_WIDTH" ]; then
      OUTPUT="$PLAY_STATE ${TITLE:0:$MAX_TITLE_WIDTH-1}…"
    fi
  else
    exit 0
  fi
fi

if [ -z "$OUTPUT" ]; then
  exit 0
fi

OUT=" $OUTPUT $TIME "
ONLY_OUT=" $OUTPUT "
TIME_INDEX=${#ONLY_OUT}
OUTPUT_LENGTH=${#OUT}

if [[ -n "$DURATION" ]] && [[ -n "$POSITION" ]] && [ "$DURATION" -gt 0 ]; then
  PERCENT=$((POSITION * 100 / DURATION))
  if [ "$PERCENT" -lt 0 ]; then
    PERCENT=0
  elif [ "$PERCENT" -gt 100 ]; then
    PERCENT=100
  fi
else
  PERCENT=0
fi

PROGRESS=$((OUTPUT_LENGTH * PERCENT / 100))
O=" $OUTPUT"

if [ "$PROGRESS" -le "$TIME_INDEX" ]; then
  echo "#[nobold,fg=$BG_COLOR,bg=$ACCENT_COLOR]${O:0:PROGRESS}#[fg=$ACCENT_COLOR,bg=$BG_BAR]${O:PROGRESS:TIME_INDEX} #[fg=$TIME_COLOR,bg=$BG_BAR]$TIME "
else
  DIFF=$((PROGRESS - TIME_INDEX))
  echo "#[nobold,fg=$BG_COLOR,bg=$ACCENT_COLOR]${O:0:TIME_INDEX} #[fg=$BG_BAR,bg=$ACCENT_COLOR]${OUT:TIME_INDEX:DIFF}#[fg=$TIME_COLOR,bg=$BG_BAR]${OUT:PROGRESS}"
fi
