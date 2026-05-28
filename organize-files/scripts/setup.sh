#!/usr/bin/env zsh
# Idempotent setup for organize-files: data dir and default config.

set -euo pipefail

SCRIPT_DIR="${0:A:h}"
DATA_DIR="${FILE_ORGANIZER_DATA:-$HOME/.cursor/file-organizer}"
CONFIG="$DATA_DIR/config.json"

mkdir -p "$DATA_DIR"
chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null || true

if [[ ! -f "$CONFIG" ]]; then
  cat > "$CONFIG" <<'EOF'
{
  "scan_paths": ["~/Downloads", "~/Documents", "~"],
  "data_dir": "~/.cursor/file-organizer",
  "phd_root": "~/Documents/博士相关资料",
  "downloads_staging": "~/Downloads/_整理",
  "size_alert_mb": 100
}
EOF
  echo "已创建默认配置: $CONFIG" >&2
fi
