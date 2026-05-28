#!/usr/bin/env zsh
# Build plan.json draft from inventory.json
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
source "${SCRIPT_DIR}/setup.sh"

DATA_DIR="${FILE_ORGANIZER_DATA:-$HOME/.cursor/file-organizer}"
INVENTORY="$DATA_DIR/inventory.json"
PLAN="$DATA_DIR/plan.json"
SIZE_ALERT_MB="${FILE_ORGANIZER_SIZE_MB:-100}"
SIZE_ALERT_BYTES=$((SIZE_ALERT_MB * 1024 * 1024))

[[ -f "$INVENTORY" ]] || { echo "Missing $INVENTORY — run file-organizer-scan.sh first" >&2; exit 1; }

iso_now() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

jq -n \
  --arg created_at "$(iso_now)" \
  --argjson size_alert "$SIZE_ALERT_BYTES" \
  --slurpfile inv "$INVENTORY" \
  '
  ($inv[0]) as $inv |
  ($inv.top_level_items | map(select(.skip == false))) as $active |
  [
    $active[] |
    {
      source: .path,
      target: (.suggested_target + "/" + .name),
      category: .suggested_category,
      reason: ("扩展名/关键词 → " + .suggested_category),
      size_bytes: .size_bytes,
      status: "pending"
    }
  ] as $moves |
  [
    $inv.top_level_items[] | select(.skip == true) |
    { path: .path, reason: .skip_reason }
  ] as $skips |
  [
    $active[] | select(.size_bytes > $size_alert) |
    { path: .path, size_bytes: .size_bytes, size_human: ((.size_bytes / 1048576 * 10 | floor) / 10 | tostring + " MB") }
  ] as $large |
  {
    created_at: $created_at,
    approved: false,
    approved_at: null,
    moves: $moves,
    skips: $skips,
    conflicts: [],
    large_items: $large
  }
  ' > "$PLAN"

move_count=$(jq '.moves | length' "$PLAN")
skip_count=$(jq '.skips | length' "$PLAN")
echo "Wrote $PLAN ($move_count moves, $skip_count skips)"
