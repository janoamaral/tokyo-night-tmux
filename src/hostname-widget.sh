#!/usr/bin/env bash

# Imports
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
. "${ROOT_DIR}/lib/coreutils-compat.sh"

# Check if enabled
ENABLED=$(tmux show-option -gv @tokyo-night-tmux_show_hostname 2>/dev/null)
[[ ${ENABLED} -ne 1 ]] && exit 0

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $CURRENT_DIR/themes.sh

hostname=$(hostnamectl hostname)

echo "#[fg=red,bold,bg=default]░ @ #[fg=brightwhite,bg=${THEME[background]}]${hostname}"
