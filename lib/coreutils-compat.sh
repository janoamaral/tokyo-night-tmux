#!/usr/bin/env bash

# Compatibility functions for macOS
if [[ "$(uname)" == "Darwin" ]]; then
  HOMEBREW_PREFIX="$(brew --prefix 2>/dev/null)"
  if [[ -z "$HOMEBREW_PREFIX" ]]; then
    # Fallback to common Homebrew locations
    if [[ -d "/opt/homebrew" ]]; then
      HOMEBREW_PREFIX="/opt/homebrew"
    elif [[ -d "/usr/local" ]]; then
      HOMEBREW_PREFIX="/usr/local"
    fi
  fi
  if [[ -n "$HOMEBREW_PREFIX" ]]; then
    # Use Homebrew bash (required for associative arrays / bash 4+)
    if [[ -d "$HOMEBREW_PREFIX/opt/bash" ]]; then
      export PATH="$HOMEBREW_PREFIX/opt/bash/bin:$PATH"
    fi
    # Use GNU coreutils if available
    if [[ -d "$HOMEBREW_PREFIX/opt/coreutils" ]]; then
      export PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
    fi
    # Use GNU awk if available
    if [[ -d "$HOMEBREW_PREFIX/opt/gawk" ]]; then
      export PATH="$HOMEBREW_PREFIX/opt/gawk/libexec/gnubin:$PATH"
    fi
    # Use GNU sed if available
    if [[ -d "$HOMEBREW_PREFIX/opt/gsed" ]]; then
      export PATH="$HOMEBREW_PREFIX/opt/gsed/libexec/gnubin:$PATH"
    fi
    # Use Homebrew bc if available
    if [[ -d "$HOMEBREW_PREFIX/opt/bc" ]]; then
      export PATH="$HOMEBREW_PREFIX/opt/bc/bin:$PATH"
    fi
  fi
fi
