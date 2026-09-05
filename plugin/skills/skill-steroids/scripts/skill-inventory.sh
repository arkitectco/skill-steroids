#!/usr/bin/env bash
# Lists unique SKILL.md files. Read-only.
#   --library (default)  user skill roots, deduped by realpath
#   --pack               this plugin pack only
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

MODE="library"
if [[ "${1:-}" == "--pack" ]]; then
  MODE="pack"
elif [[ "${1:-}" == "--library" || -z "${1:-}" ]]; then
  MODE="library"
else
  echo "Usage: skill-inventory.sh [--library|--pack]" >&2
  exit 2
fi

emit_under() {
  local root="$1"
  [[ -d "$root" ]] || return 0
  find -L "$root" -name 'SKILL.md' -print 2>/dev/null || true
}

unique_paths() {
  local f resolved
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    resolved="$(cd -P "$(dirname "$f")" && pwd)/$(basename "$f")"
    printf '%s\n' "$resolved"
  done | sort -u
}

if [[ "$MODE" == "pack" ]]; then
  echo "# scan: pack"
  echo "# root: $PACK_ROOT"
  emit_under "$PACK_ROOT" | unique_paths
  exit 0
fi

cursor_root="${SKILL_STEROIDS_CURSOR_SKILLS:-$HOME/.cursor/skills}"
agents_root="${SKILL_STEROIDS_AGENTS_SKILLS:-$HOME/.agents/skills}"
claude_root="${SKILL_STEROIDS_CLAUDE_SKILLS:-$HOME/.claude/skills}"

echo "# scan: library (unique realpath; Cursor/Agents/Claude copies count once)"
echo "# roots: $cursor_root | $agents_root | $claude_root"

{
  emit_under "$cursor_root"
  emit_under "$agents_root"
  emit_under "$claude_root"
} | unique_paths
