#!/usr/bin/env bash

# Value parser for nowplaying-cli
parse_npcli_value() {
    echo "$NPCLI_STATUS" | grep "$1" | awk -F '= ' '{print $2}' | tr -d '";'
}

ACCENT_COLOR="#7aa2f7"
SECONDARY_COLOR="#24283B"
BG_COLOR="#1F2335"
BG_BAR="#15161e"
TIME_COLOR="#414868"

if [[ $1 =~ ^[[:digit:]]+$  ]]; then
    MAX_TITLE_WIDTH=$1
  else
    MAX_TITLE_WIDTH=$(($(tmux display -p '#{window_width}' 2> /dev/null || echo 120) - 90))
fi

# playerctl
if command -v playerctl > /dev/null; then
  PLAYER_STATUS=$(playerctl -a metadata --format "{{status}};{{mpris:length}};{{position}};{{title}}" | grep -m1 "Playing")
  STATUS="playing"

  # There is no playing media, check for paused media
  if [ -z "$PLAYER_STATUS" ]; then
    PLAYER_STATUS=$(playerctl -a metadata --format "{{status}};{{mpris:length}};{{position}};{{title}}" | grep -m1 "Paused")
    STATUS="paused"
  fi

  TITLE=$(echo "$PLAYER_STATUS" | cut -d';' --fields=4)
  DURATION=$(echo "$PLAYER_STATUS" | cut -d';' --fields=2)
  POSITION=$(echo "$PLAYER_STATUS" | cut -d';' --fields=3)

  # Convert position and duration to seconds from microseconds
  DURATION=$((DURATION / 1000000))
  POSITION=$((POSITION / 1000000))

  if [ "$DURATION" -eq 0 ]; then
    DURATION=-1
    POSITION=0
  fi

# nowplaying-cli
elif command -v nowplaying-cli > /dev/null; then
  NPCLI_STATUS=$(nowplaying-cli get-raw)
  if [ "$(parse_npcli_value PlaybackRate)" = "1" ]; then
    STATUS="playing"
  else
    STATUS="paused"
  fi
  TITLE=$(parse_npcli_value Title)
  if [ "$(parse_npcli_value IsAlwaysLive)" = "1" ]; then
    DURATION=-1
    POSITION=0
  else
    DURATION=$(parse_npcli_value Duration | cut -d. -f1)
    POSITION=$(parse_npcli_value ElapsedTime | cut -d. -f1)
  fi
  # If playing media with a duration, calculate POSITION from last update
  if [ "$STATUS" = "playing" ] && [ "$DURATION" -gt 0 ]; then
    # Assuming BSD date on macOS
    update_timestamp=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$(parse_npcli_value Timestamp)" +"%s")
    current_timestamp=$(date -u +"%s")
    # Calculate seconds since last update
    UPDATE_AGE=$((current_timestamp - update_timestamp))
    POSITION=$((POSITION + UPDATE_AGE))
    # Cap at DURATION
    if [ "$POSITION" -gt "$DURATION" ]; then
      POSITION=$DURATION
    fi
  fi
fi
# If POSITION, calculate the progress bar
if [ -n "$POSITION" ]; then
  P_MIN=`printf '%02d' $(($POSITION / 60))`
  P_SEC=`printf '%02d' $(($POSITION % 60))`
fi
if [ -n "$DURATION" ]; then
  D_MIN=`printf '%02d' $(($DURATION / 60))`
  D_SEC=`printf '%02d' $(($DURATION % 60))`
fi
if [ -n "$DURATION" ] && [ -n "$POSITION" ]; then
  TIME="[$P_MIN:$P_SEC / $D_MIN:$D_SEC]"
  if [ "$D_SEC" = "-1" ]; then
    TIME="[--:--]"
  fi
else
  TIME="[--:--]"
fi
if [ -n "$TITLE"  ]; then
  if [ "$STATUS" = "playing"  ]; then
    PLAY_STATE="$OUTPUT"
  else
    PLAY_STATE="$OUTPUT"
  fi
  OUTPUT="$PLAY_STATE $TITLE"

  # Only show the song title if we are over $MAX_TITLE_WIDTH characters
  if [ "${#OUTPUT}" -ge $MAX_TITLE_WIDTH  ]; then
    OUTPUT="$PLAY_STATE ${TITLE:0:$MAX_TITLE_WIDTH-1}…"
  fi
else
  OUTPUT=''
fi

MAX_TITLE_WIDTH=25
if [ "${#OUTPUT}" -ge $MAX_TITLE_WIDTH  ]; then
  OUTPUT="$PLAY_STATE ${TITLE:0:$MAX_TITLE_WIDTH-1}"
  # Remove trailing spaces
  OUTPUT="${OUTPUT%"${OUTPUT##*[![:space:]]}"}…"
fi

if [ -z "$OUTPUT" ]
then
  echo "$OUTPUT #[fg=green,bg=default]"
else
  OUT=" $OUTPUT $TIME "
  ONLY_OUT=" $OUTPUT "
  TIME_INDEX=${#ONLY_OUT}
  OUTPUT_LENGTH=${#OUT}
  PERCENT=$((POSITION * 100 / DURATION))
  PROGRESS=$((OUTPUT_LENGTH * PERCENT / 100))
  O=" $OUTPUT"

  if [ $PROGRESS -le $TIME_INDEX ]; then
    echo "#[nobold,fg=$BG_COLOR,bg=$ACCENT_COLOR]${O:0:$PROGRESS}#[fg=$ACCENT_COLOR,bg=$BG_BAR]${O:$PROGRESS:$TIME_INDEX} #[fg=$TIME_COLOR,bg=$BG_BAR]$TIME "
  else
    DIFF=$((PROGRESS - TIME_INDEX))
    echo "#[nobold,fg=$BG_COLOR,bg=$ACCENT_COLOR]${O:0:$TIME_INDEX} #[fg=$BG_BAR,bg=$ACCENT_COLOR]${OUT:$TIME_INDEX:$DIFF}#[fg=$TIME_COLOR,bg=$BG_BAR]${OUT:$PROGRESS}"
  fi
fi
