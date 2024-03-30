#!/usr/bin/env bash

SELECTED_THEME="$(echo "$TMUX_VARS" | grep '@tokyo-night-tmux_theme' | cut -d" " -f2)"


declare -A TOKYO_NIGHT_THEME_DAY=(
  [background]="#f5f5f5"
  [foreground]="#24283B"
  [comment]="#7d7d7d"
  [cyan]="#2D96FA"
  [green]="#44dfaf"
  [orange]="#e771a3"
  [pink]="#d16d9e"
  [purple]="#bb9af7"
  [red]="#f7768e"
  [yellow]="#e0af68"
  [black]="#0f0f14"
  [white]="#343b58"
)

case $SELECTED_THEME in
  "night")
    THEME=$TOKYO_NIGHT_THEME_NIGHT
    ;;
  "day")
    THEME=$TOKYO_NIGHT_THEME_DAY
    ;;
  *)
    declare -A THEME=(
      ["background"]="#1A1B26"
      ["foreground"]="#a9b1d6"
      ["black"]="#32344a"
      ["red"]="#f7768e"
      ["green"]="#9ece6a"
      ["yellow"]="#e0af68"
      ["blue"]="#7aa2f7"
      ["magenta"]="#ad8ee6"
      ["cyan"]="#449dab"
      ["white"]="#787c99"
      ["bblack"]="#444b6a"
      ["bred"]="#ff7a93"
      ["bgreen"]="#b9f27c"
      ["byellow"]="#ff9e64"
      ["bblue"]="#7da6ff"
      ["bmagenta"]="#bb9af7"
      ["bcyan"]="#0db9d7"
      ["bwhite"]="#acb0d0"
    )
    ;;
esac
