#!/usr/bin/env bash

# Imports
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
. "${ROOT_DIR}/lib/coreutils-compat.sh"

SHOW_CPU=$(tmux show-option -gv @tokyo-night-tmux_show_cpu 2>/dev/null)
if [[ $SHOW_CPU == "0" ]]; then
  exit 0
fi

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/themes.sh"
ACCEND_COLOR="${THEME[red]}"

cpu_usage="0"

if [[ $OSTYPE == "darwin"* ]]; then
  cpu_stats=$(iostat | awk 'NR==3 {print $4, $5, $6}')
  read -r user system idle <<<"$cpu_stats"

  if [[ -n "$user" && -n "$system" ]]; then
    cpu_usage=$(echo "scale=2; $user + $system" | bc)
    cpu_usage=$(printf "%.0f" "$cpu_usage")
  fi

elif [[ $OSTYPE == "linux-gnu"* ]]; then
  # todo:
  read -r cpu user nice system idle iowait irq softirq steal _ <<<$(grep '^cpu ' /proc/stat)

  total_initial=$((user + nice + system + idle + iowait + irq + softirq + steal))
  idle_initial=$idle

  sleep 0.5

  read -r cpu user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 _ <<<$(grep '^cpu ' /proc/stat)

  total_final=$((user2 + nice2 + system2 + idle2 + iowait2 + irq2 + softirq2 + steal2))
  idle_final=$idle2

  total_diff=$((total_final - total_initial))
  idle_diff=$((idle_final - idle_initial))

  if [[ $total_diff -gt 0 ]]; then
    used_diff=$((total_diff - idle_diff))
    cpu_usage=$(echo "scale=2; ($used_diff * 100) / $total_diff" | bc)
    cpu_usage=$(printf "%.0f" "$cpu_usage")
  else
    cpu_usage=0
  fi

else
  echo "#[nobold,fg=$ACCEND_COLOR]░  $RESETUnsupported "
  exit 0
fi

if [[ -z "$cpu_usage" || "$cpu_usage" -lt 0 || "$cpu_usage" -gt 100 ]]; then
  cpu_usage="0"
fi

echo "#[nobold,fg=$ACCEND_COLOR]░  $RESET${cpu_usage}% "
