#!/usr/bin/env bash

# Imports
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
. "${ROOT_DIR}/lib/coreutils-compat.sh"

# Grab global variable for showing datetime widget, only hide if explicitly disabled
SHOW_DATETIME=$(tmux show-option -gv @tokyo-night-tmux_show_datetime 2>/dev/null)
if [[ $SHOW_DATETIME == "0" ]]; then
  exit 0
fi

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $CURRENT_DIR/themes.sh

# Assign values based on user config
date_format=$(tmux show-option -gv @tokyo-night-tmux_date_format 2>/dev/null)
time_format=$(tmux show-option -gv @tokyo-night-tmux_time_format 2>/dev/null)

date_string=""
time_string=""

if [[ $date_format == "YMD" ]]; then
  # Year Month Day date format
  date_string=" %Y-%m-%d"
elif [[ $date_format == "MDY" ]]; then
  # Month Day Year date format
  date_string=" %m-%d-%Y"
elif [[ $date_format == "DMY" ]]; then
  # Day Month Year date format
  date_string=" %d-%m-%Y"
elif [[ $date_format == "hide" ]]; then
  # Day Month Year date format
  date_string=""
else
  # Default to YMD date format if not specified
  date_string=" %Y-%m-%d"
fi

if [[ $time_format == "12H" ]]; then
  # 12-hour format with AM/PM
  time_string="%I:%M %p "
elif [[ $time_format == "hide" ]]; then
  # 24-hour format
  time_string=""
else
  # Default to 24-hour format if not specified
  time_string="%H:%M "
fi

separator=""
if [[ $date_string && $time_string ]]; then
  separator="❬ "
fi

echo "$RESET#[fg=${THEME[foreground]},bg=${THEME[bblack]}]$date_string $separator$time_string"
