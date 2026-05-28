#!/usr/bin/env zsh
# Pull ai-media.env from private GitHub repo to ~/.config/ai-media/.env

set -euo pipefail

REPO="${GUANJUN_SECRETS_REPO:-wuguanjun0627/guanjun-skill-secrets}"
REMOTE_FILE="${GUANJUN_SECRETS_FILE:-ai-media.env}"
DEST="${HOME}/.config/ai-media/.env"

if ! command -v gh &>/dev/null; then
  echo "错误: 未找到 gh CLI。请安装: brew install gh && gh auth login" >&2
  exit 1
fi

if ! gh auth status &>/dev/null; then
  echo "错误: 未登录 GitHub。请执行: gh auth login" >&2
  exit 1
fi

mkdir -p "$(dirname "$DEST")"

if ! gh api "repos/${REPO}" &>/dev/null; then
  echo "错误: 无法访问 private 仓库 ${REPO}（需仓库所有者或协作者权限）" >&2
  exit 1
fi

python3 - <<'PY' "$REPO" "$REMOTE_FILE" "$DEST"
import base64
import json
import subprocess
import sys

repo, remote_file, dest = sys.argv[1:4]
raw = subprocess.check_output(
    ["gh", "api", f"repos/{repo}/contents/{remote_file}"],
    text=True,
)
payload = json.loads(raw)
content_b64 = payload.get("content", "").replace("\n", "")
if not content_b64:
    raise SystemExit(f"错误: 仓库中未找到 {remote_file}")
with open(dest, "wb") as f:
    f.write(base64.b64decode(content_b64))
PY

chmod 600 "$DEST"
echo "已同步: ${DEST}  ←  ${REPO}/${REMOTE_FILE}"
