#!/usr/bin/env bash

# Read the preferred time format from the argument
time_format="$1"

if [[ "$time_format" == "12H" ]]; then
    # 12-hour format with AM/PM
    echo "%I:%M %p"
else
    # Default 24-hour format
    echo "%H:%M"
fi
