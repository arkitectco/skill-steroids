#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

check_manifest() {
  local label="$1"
  local manifest="$2"
  local skills_rel
  skills_rel="$(jq -r '.skills' "$manifest")"
  local skills_dir
  skills_dir="$(cd "$(dirname "$manifest")" && cd "$skills_rel" && pwd)"
  if [[ -f "$skills_dir/SKILL.md" && -f "$skills_dir/scripts/govern-check.sh" ]]; then
    echo "✓ $label → $skills_dir"
  else
    echo "✗ $label: pack not found at $skills_dir"
    FAIL=1
  fi
}

check_hooks() {
  local label="$1"
  local manifest="$2"
  local hooks_rel
  hooks_rel="$(jq -r '.hooks // empty' "$manifest")"
  if [[ -z "$hooks_rel" ]]; then
    echo "✗ $label: missing hooks field"
    FAIL=1
    return
  fi
  local hooks_file
  hooks_file="$(cd "$(dirname "$manifest")" && cd "$(dirname "$hooks_rel")" && pwd)/$(basename "$hooks_rel")"
  if [[ -f "$hooks_file" ]]; then
    echo "✓ $label hooks → $hooks_file"
  else
    echo "✗ $label: hooks not found at $hooks_file"
    FAIL=1
  fi
}

PACK="$ROOT/packages/skill-pack"
if [[ -f "$PACK/using-skill-steroids/SKILL.md" ]]; then
  echo "✓ bootstrap → $PACK/using-skill-steroids/SKILL.md"
else
  echo "✗ bootstrap skill missing"
  FAIL=1
fi

check_manifest "Cursor" "$ROOT/.cursor-plugin/plugin.json"
check_manifest "Claude" "$ROOT/.claude-plugin/plugin.json"
check_manifest "Codex" "$ROOT/.codex-plugin/plugin.json"

check_hooks "Cursor" "$ROOT/.cursor-plugin/plugin.json"
check_hooks "Claude" "$ROOT/.claude-plugin/plugin.json"
check_hooks "Codex" "$ROOT/.codex-plugin/plugin.json"

"$ROOT/scripts/bump-plugin-version.sh" --check || FAIL=1

if [[ "$FAIL" -eq 0 ]]; then
  echo "Plugin manifests: PASS"
else
  echo "Plugin manifests: FAIL"
  exit 1
fi
