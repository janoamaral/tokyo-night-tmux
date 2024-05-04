#!/usr/bin/env bash
#<------------------------------Netspeed widget for TMUX------------------------------------>
# author : @tribhuwan-kumar
# email : freakybytes@duck.com
#<------------------------------------------------------------------------------------------>

# Check if enabled
ENABLED=$(tmux show-option -gv @tokyo-night-tmux_show_netspeed 2>/dev/null)
[[ ${ENABLED} -ne 1 ]] && exit 0

# Imports
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
source "$ROOT_DIR/src/themes.sh"
source "$ROOT_DIR/lib/netspeed.sh"

# Get network interface
INTERFACE=$(tmux show-option -gv @tokyo-night-tmux_netspeed_iface 2>/dev/null)
# Show IP address
SHOW_IP=$(tmux show-option -gv @tokyo-night-tmux_netspeed_showip 2>/dev/null)
# Time between refresh
TIME_DIFF=$(tmux show-option -gv @tokyo-night-tmux_netspeed_refresh 2>/dev/null)
TIME_DIFF=${TIME_DIFF:-1}

# Icons
declare -A NET_ICONS
NET_ICONS[wifi_up]="#[fg=${THEME[foreground]}]\U000f05a9"  # nf-md-wifi
NET_ICONS[wifi_down]="#[fg=${THEME[red]}]\U000f05aa"       # nf-md-wifi_off
NET_ICONS[wired_up]="#[fg=${THEME[foreground]}]\U000f0318" # nf-md-lan_connect
NET_ICONS[wired_down]="#[fg=${THEME[red]}]\U000f0319"      # nf-md-lan_disconnect
NET_ICONS[traffic_tx]="#[fg=${THEME[bblue]}]\U000f06f6"    # nf-md-upload_network
NET_ICONS[traffic_rx]="#[fg=${THEME[bgreen]}]\U000f06f4"   # nf-md-download_network
NET_ICONS[ip]="#[fg=${THEME[foreground]}]\U000f0a5f"       # nf-md-ip

# Determine interface if not set
if [[ -z $INTERFACE ]]; then
  INTERFACE=$(find_interface)
  [[ -z $INTERFACE ]] && exit 1
  # Update tmux option for this session
  tmux set-option -g @tokyo-night-tmux_netspeed_iface "$INTERFACE"
fi

# Echo network speed
read -r RX1 TX1 < <(get_bytes "$INTERFACE")
sleep "$TIME_DIFF"
read -r RX2 TX2 < <(get_bytes "$INTERFACE")

RX_DIFF=$((RX2 - RX1))
TX_DIFF=$((TX2 - TX1))

RX_SPEED="#[fg=${THEME[foreground]}]$(readable_format "$RX_DIFF" "$TIME_DIFF")"
TX_SPEED="#[fg=${THEME[foreground]}]$(readable_format "$TX_DIFF" "$TIME_DIFF")"

# Interface icon
if [[ ${INTERFACE} == "en0" ]] || [[ -d /sys/class/net/${INTERFACE}/wireless ]]; then
  IFACE_TYPE="wifi"
else
  IFACE_TYPE="wired"
fi

# Detect interface IPv4 and state
if IPV4_ADDR=$(interface_ipv4 "$INTERFACE"); then
  IFACE_STATUS="up"
else
  IFACE_STATUS="down"
fi

NETWORK_ICON=${NET_ICONS[${IFACE_TYPE}_${IFACE_STATUS}]}

OUTPUT="${RESET}░ ${NET_ICONS[traffic_rx]} $RX_SPEED ${NET_ICONS[traffic_tx]} $TX_SPEED $NETWORK_ICON #[dim]$INTERFACE "
if [[ ${SHOW_IP} -ne 0 ]] && [[ -n $IPV4_ADDR ]]; then
  OUTPUT+="${NET_ICONS[ip]} #[dim]$IPV4_ADDR "
fi

echo -e "$OUTPUT"
