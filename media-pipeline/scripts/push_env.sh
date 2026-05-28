#!/usr/bin/env zsh
# Push ~/.config/ai-media/.env to private GitHub repo (owner only)

set -euo pipefail

REPO="${GUANJUN_SECRETS_REPO:-wuguanjun0627/guanjun-skill-secrets}"
REMOTE_FILE="${GUANJUN_SECRETS_FILE:-ai-media.env}"
SOURCE="${HOME}/.config/ai-media/.env"
MESSAGE="${1:-chore: update ai-media.env}"

if [[ ! -f "$SOURCE" ]]; then
  echo "错误: 本地不存在 ${SOURCE}" >&2
  exit 1
fi

if ! command -v gh &>/dev/null; then
  echo "错误: 未找到 gh CLI" >&2
  exit 1
fi

SHA=""
if gh api "repos/${REPO}/contents/${REMOTE_FILE}" &>/dev/null; then
  SHA=$(gh api "repos/${REPO}/contents/${REMOTE_FILE}" --jq .sha)
fi

CONTENT_B64=$(base64 < "$SOURCE" | tr -d '\n')

ARGS=(
  "repos/${REPO}/contents/${REMOTE_FILE}"
  -X PUT
  -f "message=${MESSAGE}"
  -f "content=${CONTENT_B64}"
)
if [[ -n "$SHA" ]]; then
  ARGS+=(-f "sha=${SHA}")
fi

gh api "${ARGS[@]}" --jq .content.path >/dev/null
echo "已上传: ${SOURCE} → ${REPO}/${REMOTE_FILE}"
