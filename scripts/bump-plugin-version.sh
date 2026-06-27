#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG="$REPO_ROOT/.version-bump.json"

read_json_field() {
  local file="$1" field="$2"
  local jq_path
  jq_path=$(echo "$field" | sed -E 's/\.([0-9]+)/[\1]/g' | sed 's/^/./')
  jq -r "$jq_path" "$file"
}

write_json_field() {
  local file="$1" field="$2" value="$3"
  local jq_path
  jq_path=$(echo "$field" | sed -E 's/\.([0-9]+)/[\1]/g' | sed 's/^/./')
  local tmp="${file}.tmp"
  jq "$jq_path = \"$value\"" "$file" > "$tmp" && mv "$tmp" "$file"
}

cmd_check() {
  echo "Version check:"
  local has_drift=0
  while IFS=$'\t' read -r path field; do
    local fullpath="$REPO_ROOT/$path"
    if [[ ! -f "$fullpath" ]]; then
      echo "  MISSING: $path ($field)"
      has_drift=1
      continue
    fi
    echo "  $path ($field): $(read_json_field "$fullpath" "$field")"
  done < <(jq -r '.files[] | "\(.path)\t\(.field)"' "$CONFIG")
  [[ $has_drift -eq 0 ]] || exit 1
}

cmd_bump() {
  local new_ver="$1"
  while IFS=$'\t' read -r path field; do
    write_json_field "$REPO_ROOT/$path" "$field" "$new_ver"
    echo "✓ $path → $new_ver"
  done < <(jq -r '.files[] | "\(.path)\t\(.field)"' "$CONFIG")
}

case "${1:-}" in
  --check) cmd_check ;;
  "") echo "Usage: bump-plugin-version.sh <version> | --check" >&2; exit 1 ;;
  *) cmd_bump "$1" ;;
esac
