#!/usr/bin/env bash
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# title      Typewriter                                               +
# based on   nord-tmux (https://github.com/arcticicestudio/nord-tmux) +
# version    1.0.0                                                    +
# repository https://github.com/logico-software/typewriter-tmux             +
# author     Lógico                                                   +
# email      hi@logico.com.ar                                         +
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

TYPEWRITER_TMUX_COLOR_THEME_FILE=src/typewriter.conf
TYPEWRITER_TMUX_VERSION=0.2.0
TYPEWRITER_TMUX_STATUS_CONTENT_FILE="src/typewriter-status-content.conf"
TYPEWRITER_TMUX_STATUS_CONTENT_NO_PATCHED_FONT_FILE="src/typewriter-status-content-no-patched-font.conf"
TYPEWRITER_TMUX_STATUS_CONTENT_OPTION="@typewriter_tmux_show_status_content"
TYPEWRITER_TMUX_NO_PATCHED_FONT_OPTION="@typewriter_tmux_no_patched_font"
_current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

__cleanup() {
  unset -v TYPEWRITER_TMUX_COLOR_THEME_FILE TYPEWRITER_TMUX_VERSION
  unset -v TYPEWRITER_TMUX_STATUS_CONTENT_FILE TYPEWRITER_TMUX_STATUS_CONTENT_NO_PATCHED_FONT_FILE
  unset -v TYPEWRITER_TMUX_STATUS_CONTENT_OPTION TYPEWRITER_TMUX_NO_PATCHED_FONT_OPTION
  unset -v _current_dir
  unset -f __load __cleanup
}

__load() {
  tmux source-file "$_current_dir/$TYPEWRITER_TMUX_COLOR_THEME_FILE"

  local status_content=$(tmux show-option -gqv "$TYPEWRITER_TMUX_STATUS_CONTENT_OPTION")
  local no_patched_font=$(tmux show-option -gqv "$TYPEWRITER_TMUX_NO_PATCHED_FONT_OPTION")

  if [ "$status_content" != "0" ]; then
    if [ "$no_patched_font" != "1" ]; then
      tmux source-file "$_current_dir/$TYPEWRITER_TMUX_STATUS_CONTENT_FILE"
    else
      tmux source-file "$_current_dir/$TYPEWRITER_TMUX_STATUS_CONTENT_NO_PATCHED_FONT_FILE"
    fi
  fi
}

__load
__cleanup
