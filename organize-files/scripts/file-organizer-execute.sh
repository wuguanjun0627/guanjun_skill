#!/usr/bin/env zsh
# Execute approved plan.json; write manifest.json
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
source "${SCRIPT_DIR}/setup.sh"

DATA_DIR="${FILE_ORGANIZER_DATA:-$HOME/.cursor/file-organizer}"
PLAN="$DATA_DIR/plan.json"
MANIFEST="$DATA_DIR/manifest.json"

[[ -f "$PLAN" ]] || { echo "Missing $PLAN — run file-organizer-plan.sh first" >&2; exit 1; }

approved=$(jq -r '.approved' "$PLAN")
if [[ "$approved" != "true" ]]; then
  echo "Plan not approved. Set approved=true in $PLAN or get user confirmation first." >&2
  exit 1
fi

iso_now() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

typeset -i success=0 skipped=0 failed=0
typeset -a actions_parts

resolve_target() {
  local target="$1"
  [[ ! -e "$target" ]] && { echo "$target"; return }
  local dir base ext name i=1
  dir="${target:h}"
  base="${target:t}"
  if [[ "$base" == *.* && "$base" != .* ]]; then
    ext=".${base##*.}"
    name="${base:r}"
  else
    ext=""
    name="$base"
  fi
  while [[ -e "$dir/${name}_${i}${ext}" ]]; do
    i=$((i + 1))
  done
  echo "$dir/${name}_${i}${ext}"
}

while IFS= read -r move; do
  src=$(echo "$move" | jq -r '.source')
  tgt=$(echo "$move" | jq -r '.target')
  ts="$(iso_now)"

  if [[ ! -e "$src" ]]; then
    skipped=$((skipped + 1))
    act=$(jq -n --arg ts "$ts" --arg src "$src" --arg tgt "$tgt" \
      '{timestamp:$ts,action:"move",source:$src,target:$tgt,status:"skipped",note:"source missing"}')
    actions_parts+=("$act")
    continue
  fi

  base="${src:t}"
  if [[ "$base" == *同步空间* || "$base" == .git ]]; then
    skipped=$((skipped + 1))
    act=$(jq -n --arg ts "$ts" --arg src "$src" \
      '{timestamp:$ts,action:"move",source:$src,target:null,status:"skipped",note:"protected path"}')
    actions_parts+=("$act")
    continue
  fi

  final_tgt="$tgt"
  note=""
  if [[ -e "$tgt" ]]; then
    final_tgt="$(resolve_target "$tgt")"
    note="name conflict resolved"
  fi

  mkdir -p "${final_tgt:h}"
  if mv "$src" "$final_tgt"; then
    success=$((success + 1))
    act=$(jq -n --arg ts "$ts" --arg src "$src" --arg tgt "$final_tgt" --arg note "$note" \
      '{timestamp:$ts,action:"move",source:$src,target:$tgt,status:"success",note:($note|if .=="" then null else . end)}')
  else
    failed=$((failed + 1))
    act=$(jq -n --arg ts "$ts" --arg src "$src" --arg tgt "$final_tgt" \
      '{timestamp:$ts,action:"move",source:$src,target:$tgt,status:"failed"}')
  fi
  actions_parts+=("$act")
done < <(jq -c '.moves[]' "$PLAN")

actions_json=$(printf '%s,' "${actions_parts[@]}" | sed 's/,$//')

jq -n \
  --arg executed_at "$(iso_now)" \
  --arg plan_file "$PLAN" \
  --argjson actions "[$actions_json]" \
  --argjson success "$success" \
  --argjson skipped "$skipped" \
  --argjson failed "$failed" \
  '{
    executed_at: $executed_at,
    plan_file: $plan_file,
    actions: $actions,
    summary: { success: $success, skipped: $skipped, failed: $failed }
  }' > "$MANIFEST"

echo "Done: $success moved, $skipped skipped, $failed failed"
echo "Manifest: $MANIFEST"
