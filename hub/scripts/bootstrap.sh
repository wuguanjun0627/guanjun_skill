#!/usr/bin/env zsh
# Bootstrap guanjun_skill before running any sub-skill (idempotent).

set -euo pipefail

HUB_SCRIPTS="${0:A:h}"
SKILL="${1:-all}"

resolve_root() {
  if ROOT="$("$HUB_SCRIPTS/resolve_root.sh" 2>/dev/null)"; then
    print -r -- "$ROOT"
    return 0
  fi
  "$HUB_SCRIPTS/install.sh"
}

ROOT="$(resolve_root)"
chmod +x "$ROOT"/hub/scripts/*.sh 2>/dev/null || true
chmod +x "$ROOT"/media-pipeline/scripts/*.sh 2>/dev/null || true
chmod +x "$ROOT"/organize-files/scripts/*.sh 2>/dev/null || true

run_setup() {
  local skill="$1"
  local script="$ROOT/$skill/scripts/setup.sh"
  [[ -x "$script" ]] || return 0
  echo "▶ setup: $skill" >&2
  GUANJUN_SKILL_ROOT="$ROOT" zsh "$script"
}

case "$SKILL" in
  all)
    run_setup "media-pipeline"
    run_setup "organize-files"
    ;;
  media-pipeline|media|文生图|图生视频|seedream|seedance)
    run_setup "media-pipeline"
    ;;
  organize-files|organize|整理|文件)
    run_setup "organize-files"
    ;;
  *)
    echo "未知技能: $SKILL（可选: media-pipeline, organize-files, all）" >&2
    exit 1
    ;;
esac

echo "✓ bootstrap 完成: $SKILL" >&2
