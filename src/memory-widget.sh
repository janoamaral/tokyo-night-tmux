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
convert_bytes() {
  local bytes=$1
  local gib_threshold=$((1024 * 1024 * 1024)) # 1 GiB = 1073741824 字节

  if [ "$bytes" -ge "$gib_threshold" ]; then
    # 转换为 GiB
    echo "scale=2; $bytes / $gib_threshold" | bc | awk '{printf "%.2fG", $0}'
  else
    # 转换为 MiB（1 MiB = 1024² 字节）
    echo "scale=2; $bytes / (1024 * 1024)" | bc | awk '{printf "%.2fM", $0}'
  fi
}
if [[ $OSTYPE == "darwin"* ]]; then

  # # macos
  # page_size=$(sysctl -n hw.pagesize)
  # free_pages=$(vm_stat | awk '/Pages free/ {print $3}')
  # free_memory=$(echo "scale=2; ($free_pages * $page_size) / 1024 / 1024 / 1024" | bc)
  # total_memory=$(echo "scale=2; ($(sysctl -n hw.memsize)) / 1024 / 1024 / 1024" | bc)
  # used_memory=$(echo "scale=2; $total_memory - $free_memory" | bc)
  #
  mem_array=($("${TMUX_PLUGIN_MANAGER_PATH}/tokyo-night-tmux/util/memory/memory_apple"))

  # 提取第一个元素（used_memory）和第二个元素（total_memory）
  used_memory_bytes=${mem_array[0]}
  total_memory_bytes=${mem_array[1]}
  used_memory=$(convert_bytes "$used_memory_bytes")
  total_memory=$(convert_bytes "$total_memory_bytes")
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
memory_string="${used_memory}/${total_memory}"

echo "#[nobold,fg=$ACCEND_COLOR]░  $RESET$memory_string"
