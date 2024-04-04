#!/usr/bin/env bash

# get value from tmux config
SHOW_PATH=$(tmux show-option -gv @tokyo-night-tmux_show_path 2>/dev/null)
PATH_FORMAT=$(tmux show-option -gv @tokyo-night-tmux_path_format 2>/dev/null) # full | relative

# check if not enabled
if [ "${SHOW_PATH}" == "0" ]; then
    exit 0
fi

current_path="${1}"
default_path_format="relative"
PATH_FORMAT="${PATH_FORMAT:-$default_path_format}"

# check user rquested format
if [[ "${PATH_FORMAT}" == "relative" ]]; then
  current_path="$(echo ${current_path} |  sed 's#'"$HOME"'#~#g')"
fi

echo "${current_path} ‹ "
