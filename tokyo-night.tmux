#!/usr/bin/env bash
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# title      Tokyo Night                                              +
# version    1.0.0                                                    +
# repository https://github.com/logico-dev/tokyo-night-tmux           +
# author     Lógico                                                   +
# email      hi@logico.com.ar                                         +
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

RESET="#[fg=brightwhite,bg=#15161e,nobold,noitalics,nounderscore,nodim]"
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Highlight colors
tmux set -g mode-style "fg=#a9b1d6,bg=#2A2F41"

tmux set -g message-style "bg=#7aa2f7,fg=#2A2F41"
tmux set -g message-command-style "fg=#c0caf5,bg=#2A2F41"

tmux set -g pane-border-style "fg=#2A2F41"
tmux set -g pane-active-border-style "fg=#7aa2f7"

tmux set -g status-style bg=#1A1B26
tmux set -g status-right-length 150

SCRIPTS_PATH="$CURRENT_DIR/src"
PANE_BASE="$(tmux show -g | grep pane-base-index | cut -d" " -f2 | bc)"

cmus_status="#($SCRIPTS_PATH/cmus-tmux-statusbar.sh)"
git_status="#($SCRIPTS_PATH/git-status.sh #{pane_current_path})"
wb_git_status="#($SCRIPTS_PATH/wb-git-status.sh #{pane_current_path} &)"
window_number="#($SCRIPTS_PATH/custom-number.sh #I -d)"
custom_pane="#($SCRIPTS_PATH/custom-number.sh #P -o)"
zoom_number="#($SCRIPTS_PATH/custom-number.sh #P -O)"

#+--- Bars LEFT ---+
# Session name
tmux set -g status-left "#[fg=#1F2335,bg=#6441a5,bold] #{?client_prefix,󰠠 ,#[dim]󰤂 }#[fg=#ffffff,bg=#6441a5,bold,nodim]#S $RESET"

#+--- Windows ---+
# Focus
tmux set -g window-status-current-format "#[fg=#44dfaf,bg=#1F2335]   #[fg=#a9b1d6]$window_number #[bold,nodim]#W#[nobold,dim]#{?window_zoomed_flag, $zoom_number, $custom_pane} #{?window_last_flag,,} "
# Unfocused
tmux set -g window-status-format "#[fg=#c0caf5,bg=default,none,dim]   $window_number #W#[nobold,dim]#{?window_zoomed_flag, $zoom_number, $custom_pane}#[fg=yellow,blink] #{?window_last_flag,󰁯 ,} "

  #+--- Bars RIGHT ---+
tmux set -g status-right "$cmus_status#[fg=#a9b1d6,bg=#24283B]  %Y-%m-%d #[]❬ %H:%M $git_status$wb_git_status"
tmux set -g window-status-separator ""
