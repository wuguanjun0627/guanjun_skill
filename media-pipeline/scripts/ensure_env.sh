#!/usr/bin/env zsh
# Ensure media-pipeline env is ready (calls setup.sh once per shell session).

set -euo pipefail

SCRIPT_DIR="${0:A:h}"
MARKER="/tmp/guanjun-media-setup-${USER:-user}.done"
SETUP="$SCRIPT_DIR/setup.sh"

if [[ -x "$SETUP" ]]; then
  if [[ ! -f "$MARKER" ]] || [[ "$SETUP" -nt "$MARKER" ]]; then
    GUANJUN_SKILL_ROOT="${GUANJUN_SKILL_ROOT:-${SCRIPT_DIR:h:h}}" zsh "$SETUP"
    : > "$MARKER"
  fi
fi
