#!/usr/bin/env bash

# Grab global variable for showing datetime widget, only hide if explicitly disabled
SHOW_DATETIME="$(echo "$TMUX_VARS" | grep '@tokyo-night-tmux_show_datetime' | cut -d" " -f2)"
if [[ "$SHOW_DATETIME" == "0" ]]; then
  exit 0
fi

default_date_format="YMD"
default_time_format="24H"

date_format="$(echo "$TMUX_VARS" | grep '@tokyo-night-tmux_date_format' | cut -d" " -f2)"
time_format="$(echo "$TMUX_VARS" | grep '@tokyo-night-tmux_time_format' | cut -d" " -f2)"

date_format="${date_format:-$default_date_format}"
time_format="${time_format:-$default_time_format}"

date_string=""
time_string=""

if [[ "$date_format" == "YMD" ]]; then
  # Year Month Day Date Format
  date_string="%Y-%m-%d"
elif [[ "$date_format" == "MDY" ]]; then
  # Month Day Year Date Format
  date_string="%m-%d-%Y"
elif [[ "$date_format" == "DMY" ]]; then
  # Day Month Year Date Format
  date_string="%d-%m-%Y"
else
  # Default to YMD Date Format
  date_string="%Y-%m-%d"
fi

if [[ "$time_format" == "12H" ]]; then
    # 12-hour format with AM/PM
    time_string="%I:%M %p"
else
    # Default to 24-hour format
    time_string="%H:%M"
fi

echo "#[fg=#a9b1d6,bg=#24283B] $date_string #[]❬ $time_string"
