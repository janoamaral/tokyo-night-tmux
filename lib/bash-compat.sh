#!/usr/bin/env bash

ensure_bash_42() {
  local major minor candidate version homebrew_bash

  if [[ -n ${BASH_VERSINFO+x} ]]; then
    major=${BASH_VERSINFO[0]:-0}
    minor=${BASH_VERSINFO[1]:-0}
    if (( major > 4 || (major == 4 && minor >= 2) )); then
      return 0
    fi
  fi

  if [[ "$(uname)" == "Darwin" ]] && command -v brew >/dev/null 2>&1; then
    HOMEBREW_PREFIX="$(brew --prefix)"
    homebrew_bash="$HOMEBREW_PREFIX/bin/bash"
  fi

  for candidate in "$homebrew_bash" "$(command -v bash 2>/dev/null)"; do
    [[ -n $candidate && -x $candidate ]] || continue
    version="$("$candidate" -lc 'printf "%s %s" "${BASH_VERSINFO[0]:-0}" "${BASH_VERSINFO[1]:-0}"' 2>/dev/null)" || continue
    major=${version%% *}
    minor=${version##* }
    if (( major > 4 || (major == 4 && minor >= 2) )); then
      exec "$candidate" "$0" "$@"
    fi
  done

  printf '%s\n' "tokyo-night-tmux requires bash 4.2 or newer." >&2
  exit 1
}
