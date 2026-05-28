#!/usr/bin/env zsh
# Wrapper for gen_video.py — loads ~/.config/ai-media/.env via Python.

set -euo pipefail

SCRIPT_DIR="${0:A:h}"
PY_SCRIPT="${SCRIPT_DIR}/gen_video.py"

if ! command -v python3 &>/dev/null; then
  echo "错误: 未找到 python3" >&2
  exit 1
fi

source "${SCRIPT_DIR}/ensure_env.sh"

exec python3 "${PY_SCRIPT}" "$@"
