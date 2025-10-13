#!/usr/bin/env bash

# Imports
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
. "${ROOT_DIR}/lib/coreutils-compat.sh"

# 检查是否启用CPU显示，仅在明确禁用时退出
SHOW_CPU=$(tmux show-option -gv @tokyo-night-tmux_show_cpu 2>/dev/null)
if [[ $SHOW_CPU == "0" ]]; then
  exit 0
fi

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/themes.sh"
ACCEND_COLOR="${THEME[red]}" # 使用红色作为CPU指标的强调色

cpu_usage="0" # 默认值

# 根据操作系统类型选择不同的CPU获取方式
if [[ $OSTYPE == "darwin"* ]]; then
  # macOS系统：使用iostat获取CPU使用率
  cpu_stats=$(iostat | awk 'NR==3 {print $4, $5, $6}')
  read -r user system idle <<<"$cpu_stats"

  # 计算总使用率 (用户 + 系统)
  if [[ -n "$user" && -n "$system" ]]; then
    cpu_usage=$(echo "scale=2; $user + $system" | bc)
    cpu_usage=$(printf "%.0f" "$cpu_usage")
  fi

elif [[ $OSTYPE == "linux-gnu"* ]]; then
  # Linux系统：使用/proc/stat获取CPU使用率
  # 读取第一次CPU统计数据
  # todo:
  read -r cpu user nice system idle iowait irq softirq steal <<<$(grep '^cpu ' /proc/stat)
  total_initial=$((user + nice + system + idle + iowait + irq + softirq + steal))
  idle_initial=$idle

  # 等待短时间以计算使用率
  sleep 0.5

  # 读取第二次CPU统计数据
  read -r cpu user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 <<<$(grep '^cpu ' /proc/stat)
  total_final=$((user2 + nice2 + system2 + idle2 + iowait2 + irq2 + softirq2 + steal2))
  idle_final=$idle2

  # 计算差值
  total_diff=$((total_final - total_initial))
  idle_diff=$((idle_final - idle_initial))

  # 计算CPU使用率
  if [[ $total_diff -gt 0 ]]; then
    used_diff=$((total_diff - idle_diff))
    cpu_usage=$(echo "scale=2; ($used_diff * 100) / $total_diff" | bc)
    cpu_usage=$(printf "%.0f" "$cpu_usage")
  fi
else
  # 不支持的操作系统
  echo "#[nobold,fg=$ACCEND_COLOR]░  $RESETUnsupported "
  exit 0
fi

# 确保获取到有效数值
if [[ -z "$cpu_usage" || "$cpu_usage" -lt 0 || "$cpu_usage" -gt 100 ]]; then
  cpu_usage="0"
fi

# 输出格式化的CPU信息
echo "#[nobold,fg=$ACCEND_COLOR]░  $RESET${cpu_usage}% "
