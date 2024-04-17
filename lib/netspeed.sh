#!/usr/bin/env bash

# Get network transmit data
function get_bytes() {
  local interface="$1"
  if [[ "$(uname)" == "Linux" ]]; then
    awk -v interface="$interface" '$1 == interface ":" {print $2, $10}' /proc/net/dev
  elif [[ "$(uname)" == "Darwin" ]]; then
    netstat -ib | awk -v interface="$interface" '/^'"${interface}"'/ {print $7, $10}' | head -n1
  else
    # Unsupported operating system
    exit 1
  fi
}

# Convert into readable format
function readable_format() {
  local bytes=$1
  local secs=${2:-1}

  if [[ $bytes -lt 1048576 ]]; then
    echo "$(bc -l <<<"scale=1; $bytes / 1024 / $secs")KB/s"
  else
    echo "$(bc -l <<<"scale=1; $bytes / 1048576 / $secs")MB/s"
  fi
}

# Auto-determine interface
function find_interface() {
  local interface
  if [[ $(uname) == "Linux" ]]; then
    interface=$(awk '$2 == 00000000 {print $1}' /proc/net/route)
  elif [[ $(uname) == "Darwin" ]]; then
    interface=$(route get default 2>/dev/null | grep interface | awk '{print $2}')
    # If VPN, fallback to en0
    [[ ${interface:0:4} == "utun" ]] && interface="en0"
  fi
  echo "$interface"
}

# Detect interface IPv4 and status
function interface_ipv4() {
  local interface="$1"
  local ipv4_addr
  local status="up" # Default assumption
  if [[ $(uname) == "Darwin" ]]; then
    # Check for an IPv4 on macOS
    ipv4_addr=$(ipconfig getifaddr "$interface")
    [[ -z $ipv4_addr ]] && status="down"
  elif [[ $(uname) == "Linux" ]]; then
    # Use 'ip' command to check for IPv4 address
    if command -v ip >/dev/null 2>&1; then
      ipv4_addr=$(ip addr show dev "$interface" 2>/dev/null | grep "inet\b" | awk '{sub("/.*", "", $2); print $2}')
      [[ -z $ipv4_addr ]] && status="down"
    # Use 'ifconfig' command to check for IPv4 address
    elif command -v ifconfig >/dev/null 2>&1; then
      ipv4_addr=$(ifconfig "$interface" 2>/dev/null | grep "inet\b" | awk '{print $2}')
      [[ -z $ipv4_addr ]] && status="down"
    # Fallback to operstate on Linux
    elif [[ $(cat "/sys/class/net/$interface/operstate" 2>/dev/null) != "up" ]]; then
      status="down"
    fi
  fi
  echo "$ipv4_addr"
  [[ $status == "up" ]] && return 0 || return 1
}
