#!/usr/bin/env bash

# Imports
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
. "${ROOT_DIR}/lib/coreutils-compat.sh"

# get value from tmux config
SHOW_HOST=$(tmux show-option -gv @tokyo-night-tmux_show_host 2>/dev/null)
HOST_FORMAT=$(tmux show-option -gv @tokyo-night-tmux_host_format 2>/dev/null) # user | host | both (default)
RESET="#[fg=brightwhite,bg=#15161e,nobold,noitalics,nounderscore,nodim]"

# check if not enabled
if [ "${SHOW_HOST}" != "1" ]; then
  exit 0
fi

if [[ ${HOST_FORMAT} == "user" ]]; then
  host_string="$(whoami)"
elif [[ ${HOST_FORMAT} == "host" ]]; then
  host_string="$(hostname)"
else
  host_string="$(whoami)@$(hostname)"
fi

echo "#[fg=blue,bg=default]󰒋 ${RESET}#[bg=default]${host_string} "
