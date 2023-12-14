#!/usr/bin/env bash
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# title      Tokyo Night                                              +
# version    1.0.0                                                    +
# repository https://github.com/logico-dev/tokyo-night-tmux           +
# author     Lógico                                                   +
# email      hi@logico.com.ar                                         +
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

tmux set -g status-right-length 150
# Replace the location of the script.
SCRIPTS_PATH="$CURRENT_DIR/src"

tmux cmus_status="#($SCRIPTS_PATH/cmus-tmux-statusbar.sh)"
tmux git_status="#($SCRIPTS_PATH/git-status.sh #{pane_current_path})"
tmux custom_number="#($SCRIPTS_PATH/custom-number.sh #{window_index})"

#+--- Bars LEFT ---+
# Session name
tmux set -g status-left "#[fg=#15161e,bg=#2b97fa,bold] #S #[fg=#2b97fa,bg=default,nobold,noitalics,nounderscore]"
#+--- Windows ---+
# Focus
tmux set -g window-status-current-format "#[fg=#44dfaf,bg=#1F2335]   #[fg=#a9b1d6,bg=#1F2335,bold]$custom_number #W #{?window_last_flag,,} "
# Unfocused
tmux set -g window-status-format "#[fg=#c0caf5,bg=default,none,dim]   $custom_number #W #[fg=yellow,blink]#{?window_last_flag,󰁯 ,} "

#+--- Bars RIGHT ---+
tmux set -g status-right "$cmus_status#[fg=#a9b1d6,bg=#24283B]  %Y-%m-%d #[]❬ %H:%M $git_status"
tmux set -g window-status-separator ""
