#!/usr/bin/env zsh
# Idempotent setup for media-pipeline: dirs, keys, optional openai package.

set -euo pipefail

SCRIPT_DIR="${0:A:h}"
ROOT="${GUANJUN_SKILL_ROOT:-${SCRIPT_DIR:h:h}}"
ENV_FILE="$HOME/.config/ai-media/.env"
OUT_DIR="$HOME/Projects/ai-media/output"

mkdir -p "$HOME/.config/ai-media" "$OUT_DIR"
chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null || true

if [[ ! -f "$ENV_FILE" ]] || grep -qE 'ARK_API_KEY=(ark-your-key-here|$)' "$ENV_FILE" 2>/dev/null; then
  if [[ -x "$SCRIPT_DIR/pull_env.sh" ]]; then
    "$SCRIPT_DIR/pull_env.sh" || echo "提示: 未能从 private 仓库拉取密钥（非所有者需手动配置 ${ENV_FILE}）" >&2
  fi
fi

if ! python3 -c "import openai" 2>/dev/null; then
  if python3 -m pip install --user -q openai 2>/dev/null; then
    echo "已安装 python 包: openai" >&2
  else
    echo "提示: OpenAI 生图需 pip install openai（火山生图/视频不依赖）" >&2
  fi
fi
