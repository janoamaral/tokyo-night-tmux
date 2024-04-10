#!/usr/bin/env bash
#<------------------------------Netspeed widget for TMUX------------------------------------>
# author : @tribhuwan-kumar
# email : freakybytes@duck.com
#<------------------------------------------------------------------------------------------>

. "$(dirname "$0")/../lib/functions.sh"

# Check the global value
SHOW_NETSPEED=$(tmux show-option -gv @tokyo-night-tmux_show_netspeed)
if [ "$SHOW_NETSPEED" != "1" ]; then
  exit 0
fi

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $CURRENT_DIR/themes.sh

# Get network interface
INTERFACE=$(tmux show-option -gv @tokyo-night-tmux_netspeed_iface 2>/dev/null)

# Get network transmit data from /proc/net/dev
get_bytes() {
  local interface="$1"
  if [[ "$(uname)" == "Linux" ]]; then
    awk -v interface="$interface" '$1 == interface ":" {print $2, $10}' /proc/net/dev
  elif [[ "$(uname)" == "Darwin" ]]; then
    netstat -ib | awk -v interface="$interface" '/^'${interface}'/ {print $7, $10}'
  else
    # Unsupported operating system
    exit 1
  fi
}

# Convert into readable format
readable_format() {
  local bytes=$1

  # Convert bytes to KBps, 'bc' is dependency, 'pacman -S bc'
  local kbps=$(echo "scale=1; $bytes / 1024" | bc)
  if (($(echo "$kbps < 1" | bc -l))); then
    echo "0.0B"
  elif (($(echo "$kbps >= 1024" | bc -l))); then
    # Convert KBps to MBps
    local mbps=$(echo "scale=1; $kbps / 1024" | bc)
    echo "${mbps}MB/s"
  else
    echo "${kbps}KB/s"
  fi
}

# Echo network speed
read RX1 TX1 < <(get_bytes "$INTERFACE")
sleep 1
read RX2 TX2 < <(get_bytes "$INTERFACE")

RX_DIFF=$((RX2 - RX1))
TX_DIFF=$((TX2 - TX1))

TIME_DIFF=1

RX_SPEED=$(readable_format "$((RX_DIFF / TIME_DIFF))")
TX_SPEED=$(readable_format "$((TX_DIFF / TIME_DIFF))")

NETWORK_ICON="󰈀"

# TODO: Use a more sophisticated method to detect iface type (wifi, ethernet, etc)
if [ ${INTERFACE:0:1} == "w" ]; then
  NETWORK_ICON=""
fi

echo "${RESET}░ #[fg=${THEME[bgreen]}]󰛴${RESET} $RX_SPEED #[fg=${THEME[bblue]}]󰛶${RESET} $TX_SPEED ${NETWORK_ICON} #[dim]$INTERFACE "
