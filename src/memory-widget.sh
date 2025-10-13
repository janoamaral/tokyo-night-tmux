#!/usr/bin/env bash

# Imports
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
. "${ROOT_DIR}/lib/coreutils-compat.sh"

SHOW_MEMORY=$(tmux show-option -gv @tokyo-night-tmux_show_memory 2>/dev/null)
if [[ $SHOW_MEMORY == "0" ]]; then
  exit 0
fi

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $CURRENT_DIR/themes.sh
ACCEND_COLOR="${THEME[cyan]}"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/themes.sh"

if [[ $OSTYPE == "darwin"* ]]; then

  # macos
  page_size=$(sysctl -n hw.pagesize)
  free_pages=$(vm_stat | awk '/Pages free/ {print $3}')
  free_memory=$(echo "scale=2; ($free_pages * $page_size) / 1024 / 1024 / 1024" | bc)
  total_memory=$(echo "scale=2; ($(sysctl -n hw.memsize)) / 1024 / 1024 / 1024" | bc)
  used_memory=$(echo "scale=2; $total_memory - $free_memory" | bc)

elif command -v free &>/dev/null; then

  memory_unit="g"
  memory_info=$(free -$memory_unit | awk 'NR==2 {print $2, $3, $4, $5, $6}')

  total_memory=$(echo $memory_info | awk '{print $1}')
  used_memory=$(echo $memory_info | awk '{print $2}')
  free_memory=$(echo $memory_info | awk '{print $3}')
else
  exit 0
fi

usage_percent=$(echo "scale=2; $used_memory * 100 / $total_memory" | bc)
memory_string="${used_memory}/${total_memory}G"

echo "#[nobold,fg=$ACCEND_COLOR]░  $RESET$memory_string "
