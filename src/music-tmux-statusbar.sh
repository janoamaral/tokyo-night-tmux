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

load_playerctl_metadata() {
  local player_status

  command -v playerctl >/dev/null || return 1

  player_status=$(playerctl -a metadata --format "{{status}};{{mpris:length}};{{position}};{{title}};{{playerName}}" | grep -m1 "Playing")
  STATUS="playing"

  if [[ -z $player_status ]]; then
    player_status=$(playerctl -a metadata --format "{{status}};{{mpris:length}};{{position}};{{title}};{{playerName}}" | grep -m1 "Paused")
    STATUS="paused"
  fi

  [[ -n $player_status ]] || return 1

  TITLE=$(echo "$player_status" | cut -d';' --fields=4)
  [[ -n $TITLE ]] || return 1

  DURATION=$(echo "$player_status" | cut -d';' --fields=2)
  POSITION=$(echo "$player_status" | cut -d';' --fields=3)

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

  return 0
}

load_nowplaying_metadata() {
  local -a npcli_output npcli_properties
  declare -A npcli_values
  local i

  command -v nowplaying-cli >/dev/null || return 1
  if [[ $OSTYPE == "darwin"* ]] && [[ "$(sw_vers -productVersion | cut -d. -f1)" -ge 15 ]]; then
    return 1
  fi

  npcli_properties=(title duration elapsedTime playbackRate isAlwaysLive)
  mapfile -t npcli_output < <(nowplaying-cli get "${npcli_properties[@]}")

  for ((i = 0; i < ${#npcli_properties[@]}; i++)); do
    [[ "${npcli_output[$i]}" == "null" ]] && npcli_output[$i]=""
    npcli_values[${npcli_properties[$i]}]="${npcli_output[$i]}"
  done

  TITLE="${npcli_values[title]}"
  [[ -n $TITLE ]] || return 1

  if [[ -n "${npcli_values[playbackRate]}" ]] && [[ "${npcli_values[playbackRate]}" -gt 0 ]]; then
    STATUS="playing"
  else
    STATUS="paused"
  fi

  if [[ "${npcli_values[isAlwaysLive]}" == "1" ]]; then
    DURATION=-1
    POSITION=0
  else
    DURATION=$(normalize_number "${npcli_values[duration]}") || DURATION=""
    POSITION=$(normalize_number "${npcli_values[elapsedTime]}") || POSITION=""
  fi

  return 0
}

load_media_control_metadata() {
  local -a mdc_output mdc_properties
  declare -A mdc_values
  local i

  command -v media-control >/dev/null || return 1

  mdc_properties=(title duration elapsedTimeNow playing)
  mapfile -t mdc_output < <(
    media_json=$(media-control get --now)
    for field in "${mdc_properties[@]}"; do
      echo "$media_json" | jq -r --arg f "$field" '.[$f] // ""'
    done
  )

  for ((i = 0; i < ${#mdc_properties[@]}; i++)); do
    [[ "${mdc_output[$i]}" == "null" ]] && mdc_output[$i]=""
    mdc_values[${mdc_properties[$i]}]="${mdc_output[$i]}"
  done

  TITLE="${mdc_values[title]}"
  [[ -n $TITLE ]] || return 1

  if [[ "${mdc_values[playing]}" == "true" ]]; then
    STATUS="playing"
  else
    STATUS="paused"
  fi

  DURATION=$(normalize_number "${mdc_values[duration]}") || DURATION=""
  POSITION=$(normalize_number "${mdc_values[elapsedTimeNow]}") || POSITION=""

  return 0
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

if ! load_playerctl_metadata && ! load_nowplaying_metadata && ! load_media_control_metadata; then
  exit 0
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
