#!/usr/bin/env bats

# shellcheck source=lib/widget-reorder.sh
source "${BATS_TEST_DIRNAME}/../lib/widget-reorder.sh"

setup() {
  # Mock TMUX_VARS as it would appear from "tmux show -g"
  export TMUX_VARS="
@tokyo-night-tmux_show_right_widgets path, git, netspeed
@tokyo-night-tmux_window_id_style digital
@tokyo-night-tmux_show_git 1
"

  # Mock widget #() substitution strings (same format as in tokyo-night.tmux)
  export battery_status="#(${BATS_TEST_DIRNAME}/../src/battery-widget.sh)"
  export current_path="#(${BATS_TEST_DIRNAME}/../src/path-widget.sh #{pane_current_path})"
  export cmus_status="#(${BATS_TEST_DIRNAME}/../src/music-tmux-statusbar.sh)"
  export netspeed="#(${BATS_TEST_DIRNAME}/../src/netspeed.sh)"
  export git_status="#(${BATS_TEST_DIRNAME}/../src/git-status.sh #{pane_current_path})"
  export wb_git_status="#(${BATS_TEST_DIRNAME}/../src/wb-git-status.sh #{pane_current_path} &)"
  export date_and_time="#(${BATS_TEST_DIRNAME}/../src/datetime-widget.sh)"
  export hostname="#(${BATS_TEST_DIRNAME}/../src/hostname-widget.sh)"
}

@test "build_widget_string returns empty for unset option" {
  run build_widget_string "show_nonexistent"
  [[ -z $output ]]
}

@test "build_widget_string returns single widget" {
  # Override TMUX_VARS with a single-widget list
  export TMUX_VARS="@tokyo-night-tmux_show_right_widgets git"
  run build_widget_string "show_right_widgets"
  [[ $output == "$git_status" ]]
}

@test "build_widget_string returns widgets in specified order" {
  export TMUX_VARS="@tokyo-night-tmux_show_right_widgets datetime, git, battery"
  run build_widget_string "show_right_widgets"
  [[ $output == "${date_and_time}${git_status}${battery_status}" ]]
}

@test "build_widget_string trims whitespace around widget names" {
  export TMUX_VARS="@tokyo-night-tmux_show_right_widgets  path ,  netspeed  ,  hostname  "
  run build_widget_string "show_right_widgets"
  [[ $output == "${current_path}${netspeed}${hostname}" ]]
}

@test "build_widget_string passes through #() commands verbatim" {
  export TMUX_VARS="@tokyo-night-tmux_show_right_widgets #(~/.tmux/foo.sh arg1 arg2)"
  run build_widget_string "show_right_widgets"
  [[ $output == "#(~/.tmux/foo.sh arg1 arg2)" ]]
}

@test "build_widget_string passes through #{ format vars verbatim" {
  export TMUX_VARS="@tokyo-night-tmux_show_right_widgets #{session_name}, #{pane_current_command}"
  run build_widget_string "show_right_widgets"
  [[ $output == "#{session_name}#{pane_current_command}" ]]
}

@test "build_widget_string passes through #[ format attributes verbatim" {
  export TMUX_VARS="@tokyo-night-tmux_show_right_widgets #[fg=red]●, #[bold]text"
  run build_widget_string "show_right_widgets"
  [[ $output == "#[fg=red]●#[bold]text" ]]
}

@test "build_widget_string mixes known widgets and passthrough entries" {
  export TMUX_VARS="@tokyo-night-tmux_show_right_widgets git, #(curl -s http://status), datetime"
  run build_widget_string "show_right_widgets"
  [[ $output == "${git_status}#(curl -s http://status)${date_and_time}" ]]
}

@test "build_widget_string ignores unknown widget names silently" {
  export TMUX_VARS="@tokyo-night-tmux_show_right_widgets git, nonexistent_widget, datetime"
  run build_widget_string "show_right_widgets"
  [[ $output == "${git_status}${date_and_time}" ]]
}

@test "build_widget_string handles empty list item gracefully" {
  export TMUX_VARS="@tokyo-night-tmux_show_right_widgets git, , datetime"
  run build_widget_string "show_right_widgets"
  [[ $output == "${git_status}${date_and_time}" ]]
}
