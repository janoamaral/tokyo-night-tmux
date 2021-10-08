#!/usr/bin/env bash
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# title      Tokyo Night                                              +
# version    1.0.0                                                    +
# repository https://github.com/logico-dev/tokyo-night-tmux           +
# author     Lógico                                                   +
# email      hi@logico.com.ar                                         +
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

TYPEWRITER_TMUX_STATUS_CONTENT_FILE="src/typewriter-status-content.conf"
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CMUS_STATUS="src/cmus-tmux-statusbar.sh"

main() {
  tmux source-file "$CURRENT_DIR/$TYPEWRITER_TMUX_STATUS_CONTENT_FILE"
}

main
