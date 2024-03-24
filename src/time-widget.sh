#!/usr/bin/env bash

# Read the preferred time format from the argument
date_format="$1"
time_format="$2"

date_string = ""
time_string = ""

if [[ "$date_format" == "YMD" ]]; then
  # Year Month Day Date Format
  date_string = "%Y-%m-%d"
elif [[ "$date_format" == "MDY" ]]; then
  # Month Day Year Date Format
  date_string = "%m-%d-%Y"
elif [[ "$date_format" == "DMY" ]]; then
  # Day Month Year Date Format
  date_string = "%d-%m-%Y"
else
  # Default to YMD Date Format
  date_string = "%Y-%m-%d"
fi

if [[ "$time_format" == "12H" ]]; then
    # 12-hour format with AM/PM
    time_string = "%I:%M %p"
else
    # Default to 24-hour format
    time_string = "%H:%M"
fi

echo "#[fg=#a9b1d6,bg=#24283B] date_string #[]❬ time_string"
