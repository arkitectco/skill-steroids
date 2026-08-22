#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

resolve_pack() {
  local skills_dir="$1"
  if [[ -f "$skills_dir/SKILL.md" && -f "$skills_dir/scripts/govern-check.sh" ]]; then
    printf '%s' "$skills_dir"
    return 0
  fi
  local nested
  nested="$(find -L "$skills_dir" -mindepth 2 -maxdepth 2 -name SKILL.md 2>/dev/null | head -1)"
  if [[ -n "$nested" && -f "$(dirname "$nested")/scripts/govern-check.sh" ]]; then
    printf '%s' "$(dirname "$nested")"
    return 0
  fi
  return 1
}

plugin_root_of() {
  local manifest_dir="$1"
  local folder
  folder="$(basename "$manifest_dir")"
  case "$folder" in
    .claude-plugin|.grok-plugin)
      cd "$manifest_dir/.." && pwd
      ;;
    *)
      printf '%s' "$manifest_dir"
      ;;
  esac
}

resolve_skills_dir() {
  local manifest="$1"
  local rel="$2"
  local manifest_dir plugin_root
  manifest_dir="$(cd "$(dirname "$manifest")" && pwd)"
  plugin_root="$(plugin_root_of "$manifest_dir")"
  if [[ -d "$plugin_root/$rel" ]]; then
    cd "$plugin_root/$rel" && pwd
    return 0
  fi
  if [[ -d "$manifest_dir/$rel" ]]; then
    cd "$manifest_dir/$rel" && pwd
    return 0
  fi
  return 1
}

check_manifest() {
  local label="$1"
  local manifest="$2"
  local skills_rel
  skills_rel="$(jq -r '.skills // empty' "$manifest")"
  if [[ -z "$skills_rel" ]]; then
    echo "ℹ $label: no skills field (auto-discover)"
    return
  fi
  local skills_dir
  if ! skills_dir="$(resolve_skills_dir "$manifest" "$skills_rel")"; then
    echo "✗ $label: skills path '$skills_rel' not found"
    FAIL=1
    return
  fi
  local pack
  if pack="$(resolve_pack "$skills_dir")"; then
    echo "✓ $label → $pack"
  else
    echo "✗ $label: pack not found under $skills_dir"
    FAIL=1
  fi
}

check_hooks() {
  local label="$1"
  local manifest="$2"
  local hooks_rel
  hooks_rel="$(jq -r '.hooks // empty' "$manifest")"
  if [[ -z "$hooks_rel" ]]; then
    echo "ℹ $label: no hooks field (auto-discover hooks/hooks.json)"
    return
  fi
  local manifest_dir plugin_root hooks_file
  manifest_dir="$(cd "$(dirname "$manifest")" && pwd)"
  plugin_root="$(plugin_root_of "$manifest_dir")"
  if [[ -f "$plugin_root/$hooks_rel" ]]; then
    hooks_file="$plugin_root/$hooks_rel"
  elif [[ -f "$manifest_dir/$hooks_rel" ]]; then
    hooks_file="$manifest_dir/$hooks_rel"
  else
    echo "✗ $label: hooks not found at $hooks_rel"
    FAIL=1
    return
  fi
  echo "✓ $label hooks → $hooks_file"
}

check_no_escape() {
  local label="$1"
  local hooks_file="$2"
  if grep -E 'CLAUDE_PLUGIN_ROOT\}/\.\./' "$hooks_file" >/dev/null; then
    echo "✗ $label: hook command escapes plugin root (../)"
    FAIL=1
  else
    echo "✓ $label: hook paths stay inside plugin root"
  fi
}

PACK="$ROOT/plugin/skills/skill-steroids"
if [[ -f "$PACK/using-skill-steroids/SKILL.md" ]]; then
  echo "✓ bootstrap → $PACK/using-skill-steroids/SKILL.md"
else
  echo "✗ bootstrap skill missing"
  FAIL=1
fi

if [[ -L "$ROOT/plugin/skills/skill-steroids" || -d "$ROOT/plugin/skills/skill-steroids" ]] \
  && [[ -f "$ROOT/plugin/skills/skill-steroids/SKILL.md" ]]; then
  echo "✓ slim plugin skill → $ROOT/plugin/skills/skill-steroids"
else
  echo "✗ plugin/skills/skill-steroids missing or not a pack"
  FAIL=1
fi

if [[ -f "$ROOT/plugin/.claude-plugin/plugin.json" && -f "$ROOT/plugin/.grok-plugin/plugin.json" ]]; then
  echo "✓ plugin/.claude-plugin + plugin/.grok-plugin"
else
  echo "✗ slim plugin missing .claude-plugin or .grok-plugin manifest"
  FAIL=1
fi

source_rel="$(jq -r '.plugins[0].source' "$ROOT/.claude-plugin/marketplace.json")"
if [[ "$source_rel" == "./plugin" ]]; then
  echo "✓ marketplace source → ./plugin"
else
  echo "✗ marketplace source is '$source_rel' (want ./plugin)"
  FAIL=1
fi

check_manifest "Cursor" "$ROOT/.cursor-plugin/plugin.json"
check_manifest "Claude (repo)" "$ROOT/.claude-plugin/plugin.json"
check_manifest "Claude (plugin)" "$ROOT/plugin/.claude-plugin/plugin.json"
check_manifest "Grok (plugin)" "$ROOT/plugin/.grok-plugin/plugin.json"
check_manifest "Codex" "$ROOT/.codex-plugin/plugin.json"

check_hooks "Cursor" "$ROOT/.cursor-plugin/plugin.json"
check_hooks "Claude (repo)" "$ROOT/.claude-plugin/plugin.json"
check_hooks "Claude (plugin)" "$ROOT/plugin/.claude-plugin/plugin.json"
check_hooks "Codex" "$ROOT/.codex-plugin/plugin.json"

check_no_escape "Claude pack hooks" "$PACK/hooks/hooks.json"
check_no_escape "Claude plugin hooks" "$ROOT/plugin/hooks/hooks.json"

"$ROOT/scripts/bump-plugin-version.sh" --check || FAIL=1

if [[ "$FAIL" -eq 0 ]]; then
  echo "Plugin manifests: PASS"
else
  echo "Plugin manifests: FAIL"
  exit 1
fi
