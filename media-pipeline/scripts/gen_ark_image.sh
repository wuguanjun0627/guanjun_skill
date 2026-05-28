#!/usr/bin/env zsh
# Wrapper for gen_ark_image.py — Volcano Seedream text-to-image.

set -euo pipefail

SCRIPT_DIR="${0:A:h}"
PY_SCRIPT="${SCRIPT_DIR}/gen_ark_image.py"

if ! command -v python3 &>/dev/null; then
  echo "错误: 未找到 python3" >&2
  exit 1
fi

source "${SCRIPT_DIR}/ensure_env.sh"

exec python3 "${PY_SCRIPT}" "$@"
