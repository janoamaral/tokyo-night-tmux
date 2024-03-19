#!/usr/bin/env bash
#<------------------------------Netspeed widget for TMUX------------------------------------>
# author : @tribhuwan-kumar
# email : freakybytes@duck.com
#<------------------------------------------------------------------------------------------>

# Choose wlan0 as main interface
INTERFACE="wlan0"

# Get network transmit data from /proc/net/dev
get_bytes() {
    awk -v interface="$1" '$1 == interface ":" {print $2, $10}' /proc/net/dev
}

# Convert into readable format
readable_format() {
    local bytes=$1

    # Convert bytes to KBps, 'bc' is dependency, 'pacman -S bc'
    local kbps=$(echo "scale=1; $bytes / 1024" | bc)
    if (( $(echo "$kbps < 1" | bc -l) )); then
        echo "0.0B"
    elif (( $(echo "$kbps >= 1024" | bc -l) )); then
        # Convert KBps to MBps
        local mbps=$(echo "scale=1; $kbps / 1024" | bc)
        echo "${mbps}MB/s"
    else
        echo "${kbps}KB/s"
    fi
}

# Echo with truncate condition
while true; do
    read RX1 TX1 < <(get_bytes "$INTERFACE")
    sleep 1
    read RX2 TX2 < <(get_bytes "$INTERFACE")

    RX_DIFF=$((RX2 - RX1))
    TX_DIFF=$((TX2 - TX1))

    TIME_DIFF=1

    RX_SPEED=$(readable_format "$((RX_DIFF / TIME_DIFF))")
    TX_SPEED=$(readable_format "$((TX_DIFF / TIME_DIFF))")

    width=$(tmux display -p '#{window_width}')
    if [ "$width" -lt 115 ]; then
        echo "⮛ $RX_SPEED ⮙ $TX_SPEED"
    else
        echo "⮛ $RX_SPEED ⮙ $TX_SPEED $(date '+❬ %H:%M ❬ %Y-%m-%d')"
    fi
done
