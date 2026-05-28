#!/usr/bin/env zsh
# Auto-pull ~/.config/ai-media/.env from private GitHub repo when missing or placeholder.

set -euo pipefail

SCRIPT_DIR="${0:A:h}"
ENV_FILE="${HOME}/.config/ai-media/.env"
PULL_SCRIPT="${SCRIPT_DIR}/pull_env.sh"

needs_pull() {
  [[ ! -f "$ENV_FILE" ]] && return 0
  grep -qE '^(OPENAI_API_KEY=sk-your-key-here|ARK_API_KEY=ark-your-key-here)$' "$ENV_FILE" 2>/dev/null && return 0
  # 两个 key 都是占位符时才拉；若已有 ARK 真实 key 则跳过
  if grep -q 'ARK_API_KEY=ark-your-key-here' "$ENV_FILE" 2>/dev/null; then
    return 0
  fi
  return 1
}

if needs_pull; then
  if [[ -x "$PULL_SCRIPT" ]]; then
    "$PULL_SCRIPT" || echo "提示: 无法从 private 仓库拉取 .env，请手动配置 ${ENV_FILE}" >&2
  fi
fi
