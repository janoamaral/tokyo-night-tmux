#!/usr/bin/env bash

# Doc-coverage check: every @tokyo-night-tmux_* option surfaced in
# tokyo-night.tmux, src/, or lib/ must appear in at least one user_docs/*.md.
# Runnable without tmux. Exits non-zero on any undocumented option.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

mapfile -t opts < <(grep -rhoE '@tokyo-night-tmux_[a-z_]+' tokyo-night.tmux src lib | sort -u)

if [ "${#opts[@]}" -eq 0 ]; then
  echo "FAIL: no @tokyo-night-tmux_* options found in tokyo-night.tmux, src/, lib/" >&2
  exit 1
fi

missing=0
echo "Checking ${#opts[@]} user-facing options against user_docs/..."
echo
for o in "${opts[@]}"; do
  if grep -rqF "$o" user_docs; then
    printf '  %-45s ok\n' "$o"
  else
    printf '  %-45s MISSING in user_docs/\n' "$o" >&2
    missing=$((missing + 1))
  fi
done

echo
if [ "$missing" -gt 0 ]; then
  echo "FAIL: $missing option(s) not documented in user_docs/" >&2
  exit 1
fi

echo "PASS: all ${#opts[@]} options are documented in user_docs/."