#!/usr/bin/env bash

# Imports
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
. "${ROOT_DIR}/lib/coreutils-compat.sh"
. "${ROOT_DIR}/lib/bash-compat.sh"
ensure_bash_42 "$@"

# Check the global value
SHOW_MUSIC=$(tmux show-option -gqv @tokyo-night-tmux_show_music)

if [ "$SHOW_MUSIC" != "1" ]; then
  exit 0
fi

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/themes.sh"

ACCENT_COLOR="${THEME[blue]}"
SECONDARY_COLOR="${THEME[background]}"
BG_COLOR="${THEME[background]}"
BG_BAR="${THEME[background]}"
TIME_COLOR="${THEME[black]}"

format_timestamp() {
  local total_seconds=${1:-0}
  printf '%02d:%02d' $((total_seconds / 60)) $((total_seconds % 60))
}

normalize_number() {
  local value=${1:-}

  if [[ -z $value ]]; then
    return 1
  fi

  if [[ $value =~ ^-?[0-9]+([.][0-9]+)?$ ]]; then
    printf '%.0f' "$value"
    return 0
  fi

  return 1
}

if [[ $1 =~ ^[[:digit:]]+$ ]]; then
  MAX_TITLE_WIDTH=$1
else
  MAX_TITLE_WIDTH=$(($(tmux display -p '#{window_width}' 2>/dev/null || echo 120) - 90))
fi

if [[ $MAX_TITLE_WIDTH -lt 10 ]]; then
  MAX_TITLE_WIDTH=10
fi

STATUS=""
TITLE=""
DURATION=""
POSITION=""
OUTPUT=""
PLAY_STATE=""
TIME="[--:--]"

# playerctl
if command -v playerctl >/dev/null; then
  PLAYER_STATUS=$(playerctl -a metadata --format "{{status}};{{mpris:length}};{{position}};{{title}};{{playerName}}" | grep -m1 "Playing")
  STATUS="playing"

  if [ -z "$PLAYER_STATUS" ]; then
    PLAYER_STATUS=$(playerctl -a metadata --format "{{status}};{{mpris:length}};{{position}};{{title}};{{playerName}}" | grep -m1 "Paused")
    STATUS="paused"
  fi

  TITLE=$(echo "$PLAYER_STATUS" | cut -d';' --fields=4)
  DURATION=$(echo "$PLAYER_STATUS" | cut -d';' --fields=2)
  POSITION=$(echo "$PLAYER_STATUS" | cut -d';' --fields=3)

  if [[ -n $DURATION ]]; then
    DURATION=$((DURATION / 1000000))
  fi
  if [[ -n $POSITION ]]; then
    POSITION=$((POSITION / 1000000))
  fi

  if [[ $DURATION -eq 0 ]]; then
    DURATION=-1
    POSITION=0
  fi

# nowplaying-cli
elif command -v nowplaying-cli >/dev/null && { [[ $OSTYPE != "darwin"* ]] || { [[ $OSTYPE == "darwin"* ]] && [ "$(sw_vers -productVersion | cut -d. -f1)" -lt 15 ]; }; }; then
  NPCLI_PROPERTIES=(title duration elapsedTime playbackRate isAlwaysLive)
  mapfile -t NPCLI_OUTPUT < <(nowplaying-cli get "${NPCLI_PROPERTIES[@]}")
  declare -A NPCLI_VALUES
  for ((i = 0; i < ${#NPCLI_PROPERTIES[@]}; i++)); do
    [ "${NPCLI_OUTPUT[$i]}" = "null" ] && NPCLI_OUTPUT[$i]=""
    NPCLI_VALUES[${NPCLI_PROPERTIES[$i]}]="${NPCLI_OUTPUT[$i]}"
  done
  if [ -n "${NPCLI_VALUES[playbackRate]}" ] && [ "${NPCLI_VALUES[playbackRate]}" -gt 0 ]; then
    STATUS="playing"
  else
    STATUS="paused"
  fi
  TITLE="${NPCLI_VALUES[title]}"
  if [ "${NPCLI_VALUES[isAlwaysLive]}" = "1" ]; then
    DURATION=-1
    POSITION=0
  else
    DURATION=$(normalize_number "${NPCLI_VALUES[duration]}") || DURATION=""
    POSITION=$(normalize_number "${NPCLI_VALUES[elapsedTime]}") || POSITION=""
  fi
elif command -v media-control >/dev/null; then
  MDC_PROPERTIES=(title duration elapsedTimeNow playing)
  mapfile -t MDC_OUTPUT < <(
    media_json=$(media-control get --now)
    for field in "${MDC_PROPERTIES[@]}"; do
      echo "$media_json" | jq -r --arg f "$field" '.[$f] // ""'
    done
  )
  declare -A MDC_VALUES
  for ((i = 0; i < ${#MDC_PROPERTIES[@]}; i++)); do
    [ "${MDC_OUTPUT[$i]}" = "null" ] && MDC_OUTPUT[$i]=""
    MDC_VALUES[${MDC_PROPERTIES[$i]}]="${MDC_OUTPUT[$i]}"
  done
  if [ "${MDC_VALUES[playing]}" = "true" ]; then
    STATUS="playing"
  else
    STATUS="paused"
  fi
  TITLE="${MDC_VALUES[title]}"
  DURATION=$(normalize_number "${MDC_VALUES[duration]}") || DURATION=""
  POSITION=$(normalize_number "${MDC_VALUES[elapsedTimeNow]}") || POSITION=""
fi

if [ -n "$DURATION" ] && [ -n "$POSITION" ] && [ "$DURATION" -gt 0 ] && [ "$DURATION" -lt 3600 ]; then
  TIME="[$(format_timestamp "$POSITION") / $(format_timestamp "$DURATION")]"
fi

if [ -n "$TITLE" ]; then
  if [ "$STATUS" = "playing" ]; then
    PLAY_STATE="░ "
  else
    PLAY_STATE="░ 󰏤"
  fi
  OUTPUT="$PLAY_STATE $TITLE"

  if [ "${#OUTPUT}" -ge $MAX_TITLE_WIDTH ]; then
    OUTPUT="$PLAY_STATE ${TITLE:0:$MAX_TITLE_WIDTH-1}…"
  fi
else
  exit 0
fi

OUT="$OUTPUT $TIME "
ONLY_OUT="$OUTPUT "
TIME_INDEX=${#ONLY_OUT}
OUTPUT_LENGTH=${#OUT}

if [ -n "$DURATION" ] && [ -n "$POSITION" ] && [ "$DURATION" -gt 0 ]; then
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
O="$OUTPUT"

if [ "$PROGRESS" -le "$TIME_INDEX" ]; then
  echo "#[nobold,fg=$BG_COLOR,bg=$ACCENT_COLOR]${O:0:PROGRESS}#[fg=$ACCENT_COLOR,bg=$BG_BAR]${O:PROGRESS:TIME_INDEX} #[fg=$TIME_COLOR,bg=$BG_BAR]$TIME "
else
  DIFF=$((PROGRESS - TIME_INDEX))
  echo "#[nobold,fg=$BG_COLOR,bg=$ACCENT_COLOR]${O:0:TIME_INDEX} #[fg=$BG_BAR,bg=$ACCENT_COLOR]${OUT:TIME_INDEX:DIFF}#[fg=$TIME_COLOR,bg=$BG_BAR]${OUT:PROGRESS}"
fi
