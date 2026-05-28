#!/usr/bin/env zsh
# Resolve guanjun_skill repo root (stdout prints path).

set -euo pipefail

if [[ -n "${GUANJUN_SKILL_ROOT:-}" && -d "$GUANJUN_SKILL_ROOT" ]]; then
  print -r -- "$GUANJUN_SKILL_ROOT"
  exit 0
fi

for candidate in \
  "$HOME/guanjun_skill" \
  "$HOME/.cursor/skills/guanjun-skill-hub"; do
  if [[ -d "$candidate" ]]; then
    print -r -- "${candidate:A}"
    exit 0
  fi
done

exit 1
