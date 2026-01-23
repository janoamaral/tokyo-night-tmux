#!/usr/bin/env bash
#<------------------------------Netspeed widget for TMUX------------------------------------>
# author : @tribhuwan-kumar
# email : freakybytes@duck.com
#<------------------------------------------------------------------------------------------>
# Check if enabled
#ENABLED=$(tmux show-option -gv @tokyo-night-tmux_show_netspeed 2>/dev/null)
#[[ ${ENABLED} -ne 1 ]] && exit 0

# Imports
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
source "$ROOT_DIR/src/themes.sh"

default_terminal_icon=""
default_active_terminal_icon=""

terminal_icon="$(echo "$TMUX_VARS" | grep '@tokyo-night-tmux_terminal_icon' | cut -d" " -f2)"
active_terminal_icon="$(echo "$TMUX_VARS" | grep '@tokyo-night-tmux_active_terminal_icon' | cut -d" " -f2)"

terminal_icon="${terminal_icon:-$default_terminal_icon}"
active_terminal_icon="${active_terminal_icon:-$default_active_terminal_icon}"

#+--- Windows ---+
WINDOW_NAME=$(tmux display-message -p '#W')

# Define your criteria
if [[ "$WINDOW_NAME" == *"PRD-"* ]]; then
    tmux set -g window-status-current-format " #[bg=default,fg=#ff46aa]$RESET#[fg=#141414,bg=#ff46aa]#{?#{==:#{pane_current_command},ssh},󰣀 , }#[fg=#141414,bold,nodim]$window_number#W#[nobold]#{?window_zoomed_flag, $zoom_number, $custom_pane}#{?window_last_flag,,}#[bg=default,fg=#ff46aa]"
elif [[ "$WINDOW_NAME" == *"DEV-"* ]]; then
    tmux set -g window-status-current-format " #[bg=default,fg=${THEME[red]}]$RESET#[fg=black,bg=${THEME[green]}]#{?#{==:#{pane_current_command},ssh},󰣀 ,${active_terminal_icon} }#[fg=black,bold,nodim]$window_number#W#[nobold]#{?window_zoomed_flag, $zoom_number, $custom_pane}#{?window_last_flag,,}#[bg=default,fg=${THEME[green]}]"
else
    tmux set -g window-status-current-format " #[bg=default,fg=${THEME[green]}]$RESET#[fg=black,bg=${THEME[green]}]#{?#{==:#{pane_current_command},ssh},󰣀 ,${active_terminal_icon} }#[fg=black,bold,nodim]$window_number#W#[nobold]#{?window_zoomed_flag, $zoom_number, $custom_pane}#{?window_last_flag,,}#[bg=default,fg=${THEME[green]}]"
fi
