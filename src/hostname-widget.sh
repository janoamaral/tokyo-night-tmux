#!/usr/bin/env bash

# Imports
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
. "${ROOT_DIR}/lib/coreutils-compat.sh"

# Grab global variable for showing hostname widget, only hide if explicitly disabled
SHOW_HOSTNAME=$(tmux show-option -gv @tokyo-night-tmux_show_hostname 2>/dev/null)
if [[ $SHOW_HOSTNAME == "0" ]]; then
  exit 0
fi

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $CURRENT_DIR/themes.sh

hostname=$(hostnamectl hostname)
chassis_icon=$(hostnamectl | grep Chassis | xargs |  cut -d " " -f3)

echo "#[fg=red,bold,bg=default]░ @ #[fg=brightwhite,bg=${THEME[background]}]${hostname}"
