#!/usr/bin/env bash

SELECTED_THEME="$(echo "$TMUX_VARS" | grep '@tokyo-night-tmux_theme' | cut -d" " -f2)"

declare -A TOKYO_NIGHT_THEME_NIGHT=(
  ["background"]="#1A1B26"
  ["foreground"]="#a9b1d6"
  ["comment"]="#565f89"
  ["cyan"]="#7aa2f7"
  ["green"]="#73daca"
  ["orange"]="#e0af68"
  ["pink"]="#f7768e"
  ["purple"]="#bb9af7"
  ["red"]="#f7768e"
  ["yellow"]="#e0af68"
  ["black"]="#414868"
  ["white"]="#c0caf5"
)

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

THEME=""

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
      ["comment"]="#565f89"
      ["cyan"]="#7aa2f7"
      ["green"]="#73daca"
      ["orange"]="#e0af68"
      ["blue"]="#7aa2f7"
      ["pink"]="#f7768e"
      ["purple"]="#bb9af7"
      ["red"]="#f7768e"
      ["yellow"]="#e0af68"
      ["black"]="#414868"
      ["white"]="#c0caf5"
    )
    ;;
esac
