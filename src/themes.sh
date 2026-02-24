#!/usr/bin/env bash

# Color palettes from folke/tokyonight.nvim
# https://github.com/folke/tokyonight.nvim

SELECTED_THEME="$(tmux show-option -gv @tokyo-night-tmux_theme)"
TRANSPARENT_THEME="$(tmux show-option -gv @tokyo-night-tmux_transparent)"

case $SELECTED_THEME in
"storm")
  declare -A THEME=(
    ["background"]="#24283b"
    ["foreground"]="#c0caf5"
    ["black"]="#414868"
    ["blue"]="#7aa2f7"
    ["cyan"]="#7dcfff"
    ["green"]="#9ece6a"
    ["magenta"]="#bb9af7"
    ["red"]="#f7768e"
    ["white"]="#a9b1d6"
    ["yellow"]="#e0af68"

    ["bblack"]="#292e42"
    ["bblue"]="#7aa2f7"
    ["bcyan"]="#7dcfff"
    ["bgreen"]="#73daca"
    ["bmagenta"]="#bb9af7"
    ["bred"]="#ff9e64"
    ["bwhite"]="#565f89"
    ["byellow"]="#e0af68"
  )
  ;;

"moon")
  declare -A THEME=(
    ["background"]="#222436"
    ["foreground"]="#c8d3f5"
    ["black"]="#444a73"
    ["blue"]="#82aaff"
    ["cyan"]="#86e1fc"
    ["green"]="#c3e88d"
    ["magenta"]="#c099ff"
    ["red"]="#ff757f"
    ["white"]="#828bb8"
    ["yellow"]="#ffc777"

    ["bblack"]="#2f334d"
    ["bblue"]="#82aaff"
    ["bcyan"]="#86e1fc"
    ["bgreen"]="#4fd6be"
    ["bmagenta"]="#c099ff"
    ["bred"]="#ff966c"
    ["bwhite"]="#636da6"
    ["byellow"]="#ffc777"
  )
  ;;

"day")
  declare -A THEME=(
    ["background"]="#e1e2e7"
    ["foreground"]="#3760bf"
    ["black"]="#a1a6c5"
    ["blue"]="#2e7de9"
    ["cyan"]="#007197"
    ["green"]="#587539"
    ["magenta"]="#9854f1"
    ["red"]="#f52a65"
    ["white"]="#6172b0"
    ["yellow"]="#8c6c3e"

    ["bblack"]="#c4c8da"
    ["bblue"]="#2e7de9"
    ["bcyan"]="#007197"
    ["bgreen"]="#387068"
    ["bmagenta"]="#9854f1"
    ["bred"]="#b15c00"
    ["bwhite"]="#848cb5"
    ["byellow"]="#8c6c3e"
  )
  ;;

*)
  # Default to night theme
  declare -A THEME=(
    ["background"]="#1a1b26"
    ["foreground"]="#c0caf5"
    ["black"]="#414868"
    ["blue"]="#7aa2f7"
    ["cyan"]="#7dcfff"
    ["green"]="#9ece6a"
    ["magenta"]="#bb9af7"
    ["red"]="#f7768e"
    ["white"]="#a9b1d6"
    ["yellow"]="#e0af68"

    ["bblack"]="#292e42"
    ["bblue"]="#7aa2f7"
    ["bcyan"]="#7dcfff"
    ["bgreen"]="#73daca"
    ["bmagenta"]="#bb9af7"
    ["bred"]="#ff9e64"
    ["bwhite"]="#565f89"
    ["byellow"]="#e0af68"
  )
  ;;
esac

# Override background with "default" if transparent theme is enabled
if [ "${TRANSPARENT_THEME}" == 1 ]; then
  THEME["background"]="default"
fi

THEME['ghgreen']="#3fb950"
THEME['ghmagenta']="#A371F7"
THEME['ghred']="#d73a4a"
THEME['ghyellow']="#d29922"

RESET="#[fg=${THEME[foreground]},bg=${THEME[background]},nobold,noitalics,nounderscore,nodim]"
