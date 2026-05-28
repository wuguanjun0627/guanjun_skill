#!/usr/bin/env zsh
# Scan top-level items in given paths; write inventory.json
set -euo pipefail

DATA_DIR="${FILE_ORGANIZER_DATA:-$HOME/.cursor/file-organizer}"
PHD_ROOT="${FILE_ORGANIZER_PHD:-$HOME/Documents/博士相关资料}"
STAGING="${FILE_ORGANIZER_STAGING:-$HOME/Downloads/_整理}"
INVENTORY="$DATA_DIR/inventory.json"
ITEMS_TMP="$(mktemp)"

mkdir -p "$DATA_DIR"
trap 'rm -f "$ITEMS_TMP"' EXIT

if [[ $# -gt 0 ]]; then
  SCAN_PATHS=("$@")
else
  SCAN_PATHS=("$HOME/Downloads" "$HOME/Documents" "$HOME")
fi

typeset -a HOME_SKIP_NAMES
HOME_SKIP_NAMES=(
  Library Applications .Trash .cache .cursor .npm .nvm
  .ssh .config .local Public Movies Music Pictures Desktop
)

should_skip() {
  local parent="$1" name="$2" full="$3"
  [[ "$full" == "$STAGING"* || "$full" == "$PHD_ROOT"* ]] && return 0
  [[ "$name" == "_整理" || "$name" == ".DS_Store" || "$name" == ".localized" ]] && return 0
  [[ "$name" == .* && "$name" != .. && "$name" != . ]] && return 0
  [[ "$name" == *.swp || "$name" == *.tmp || "$name" == '~$'* || "$name" == .~lock* ]] && return 0
  if [[ "$parent" == "$HOME" ]]; then
    for skip in "${HOME_SKIP_NAMES[@]}"; do
      [[ "$name" == "$skip" ]] && return 0
    done
  fi
  [[ "$name" == *同步空间* || "$name" == *iCloud* || "$name" == *OneDrive* || "$name" == *Dropbox* ]] && return 0
  [[ "$name" == .git || "$name" == node_modules || "$name" == .venv || "$name" == __pycache__ ]] && return 0
  [[ "$name" == '~$'* || "$name" == .~lock* ]] && return 0
  return 1
}

skip_reason_for() {
  local parent="$1" name="$2" full="$3"
  [[ "$full" == "$STAGING"* || "$name" == "_整理" ]] && { echo "已在整理目录"; return }
  [[ "$full" == "$PHD_ROOT"* ]] && { echo "已在博士资料目录"; return }
  [[ "$name" == *同步空间* || "$name" == *iCloud* ]] && { echo "云同步根目录"; return }
  [[ "$name" == .* ]] && { echo "隐藏/系统文件"; return }
  [[ "$name" == *.swp ]] && { echo "编辑器临时文件"; return }
  [[ "$name" == .git || "$name" == node_modules ]] && { echo "项目内部目录"; return }
  [[ "$name" == '~$'* ]] && { echo "Office临时文件"; return }
  echo "系统/排除项"
}

get_ext() {
  local n="${1:-}"
  [[ -z "$n" ]] && { echo ""; return }
  local ext="${n##*.}"
  [[ "$ext" == "$n" ]] && echo "" || echo ".${ext:l}"
}

suggest_category() {
  local name="$1" ext="$2" lower="${name:l}"
  case "$ext" in
    .crdownload|.part|.download) echo "09_未完成下载"; return ;;
    .dmg|.pkg|.exe|.msi) echo "06_软件安装包"; return ;;
    .jpg|.jpeg|.png|.gif|.webp|.heic|.mp4|.mov|.avi|.mkv) echo "04_图片与视频"; return ;;
    .ppt|.pptx|.key) echo "03_汇报演示"; return ;;
    .pdf) echo "01_论文文献"; return ;;
    .py|.js|.ts|.go|.rs|.java|.cpp|.c|.h|.zip|.tar|.gz) echo "02_代码与项目"; return ;;
    .doc|.docx|.xls|.xlsx|.csv|.txt|.md|.rtf) echo "05_文档表格"; return ;;
  esac
  [[ "$lower" == *nerf* || "$lower" == *splat* || "$lower" == *unilat* || "$lower" == *cryo* ]] && { echo "02_代码与项目"; return }
  [[ "$lower" == *paper* || "$lower" == *arxiv* || "$lower" == *bib* || "$lower" == *thesis* || "$lower" == *文献* || "$lower" == *论文* ]] && { echo "01_论文文献"; return }
  [[ "$lower" == *poster* || "$lower" == *slide* || "$lower" == *组会* || "$lower" == *汇报* ]] && { echo "03_汇报演示"; return }
  [[ "$lower" == *报销* || "$lower" == *入党* || "$lower" == *行政* || "$lower" == *实习* ]] && { echo "07_行政事务"; return }
  [[ "$lower" == *课程* || "$lower" == *homework* || "$lower" == *lecture* || "$lower" == *作业* ]] && { echo "08_课程学习"; return }
  [[ "$lower" == *resume* || "$lower" == *简历* ]] && { echo "10_个人与生活"; return }
  echo "11_临时杂项"
}

iso_now() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

for scan_path in "${SCAN_PATHS[@]}"; do
  [[ -d "$scan_path" ]] || continue
  while IFS= read -r -d '' entry; do
    name="${entry:t}"
    [[ "$name" == ".DS_Store" ]] && continue

    if [[ -d "$entry" ]]; then
      size=0; type="directory"; ext=""
    else
      size=$(stat -f%z "$entry" 2>/dev/null || echo 0)
      type="file"
      ext="$(get_ext "$name")"
    fi
    modified=$(stat -f%Sm -t "%Y-%m-%dT%H:%M:%SZ" "$entry" 2>/dev/null || iso_now)

    skip=false; reason=""; cat=""; target=""
    if should_skip "$scan_path" "$name" "$entry"; then
      skip=true
      reason="$(skip_reason_for "$scan_path" "$name" "$entry")"
    else
      cat="$(suggest_category "$name" "$ext")"
      target="$STAGING/$cat"
    fi

    jq -nc \
      --arg path "$entry" --arg name "$name" --arg parent "$scan_path" \
      --arg type "$type" --argjson size "$size" --arg ext "$ext" \
      --arg modified "$modified" --arg cat "$cat" --arg target "$target" \
      --argjson skip "$skip" --arg reason "$reason" \
      '{path:$path,name:$name,parent:$parent,type:$type,size_bytes:$size,extension:$ext,modified_at:$modified,suggested_category:$cat,suggested_target:$target,skip:$skip,skip_reason:($reason|if .=="" then null else . end)}' >> "$ITEMS_TMP"
  done < <(find "$scan_path" -mindepth 1 -maxdepth 1 ! -name '.DS_Store' -print0 2>/dev/null)
done

paths_json=$(printf '%s\n' "${SCAN_PATHS[@]}" | jq -R . | jq -s .)

if [[ -s "$ITEMS_TMP" ]]; then
  items_json=$(jq -s '.' "$ITEMS_TMP")
else
  items_json='[]'
fi

jq -n \
  --arg scanned_at "$(iso_now)" \
  --argjson scan_paths "$paths_json" \
  --arg phd "$PHD_ROOT" \
  --arg staging "$STAGING" \
  --argjson items "$items_json" \
  --argjson summary "$(echo "$items_json" | jq '{
    total_items: length,
    total_size_bytes: ([.[] | select(.skip == false) | .size_bytes] | add // 0),
    skipped_count: ([.[] | select(.skip == true)] | length),
    file_type_counts: ([.[] | select(.skip == false and .extension != "") | .extension] | group_by(.) | map({key: .[0], value: length}) | from_entries),
    suggested_categories: ([.[] | select(.skip == false and .suggested_category != "") | .suggested_category] | group_by(.) | map({key: .[0], value: length}) | from_entries)
  }')" \
  '{scanned_at:$scanned_at,scan_paths:$scan_paths,config:{phd_root:$phd,downloads_staging:$staging},top_level_items:$items,summary:$summary}' \
  > "$INVENTORY"

item_count=$(jq '.summary.total_items' "$INVENTORY")
skipped=$(jq '.summary.skipped_count' "$INVENTORY")
echo "Wrote $INVENTORY ($item_count items, $skipped skipped)"
