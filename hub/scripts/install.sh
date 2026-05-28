#!/usr/bin/env zsh
# First-time install: clone guanjun_skill + symlink into Cursor skills.

set -euo pipefail

TARGET="${GUANJUN_SKILL_ROOT:-$HOME/guanjun_skill}"
LINK="${GUANJUN_SKILL_LINK:-$HOME/.cursor/skills/guanjun-skill-hub}"
REPO="${GUANJUN_REPO:-wuguanjun0627/guanjun_skill}"

mkdir -p "$HOME/.cursor/skills"

if [[ ! -d "$TARGET/.git" ]]; then
  if command -v gh &>/dev/null && gh auth status &>/dev/null; then
    gh repo clone "$REPO" "$TARGET"
  else
    git clone "https://github.com/${REPO}.git" "$TARGET"
  fi
fi

if [[ ! -L "$LINK" && ! -d "$LINK" ]]; then
  ln -sf "$TARGET" "$LINK"
  echo "已创建 symlink: $LINK → $TARGET"
fi

print -r -- "$TARGET"
