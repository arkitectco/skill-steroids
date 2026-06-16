#!/usr/bin/env bash
# Lists SKILL.md files under common skill roots. Read-only.
set -euo pipefail

roots=(
  "$HOME/.cursor/skills"
  "$HOME/.agents/skills"
  "$HOME/.claude/skills"
)

for root in "${roots[@]}"; do
  if [[ -d "$root" ]]; then
    echo "=== $root ==="
    find "$root" -name 'SKILL.md' -not -path '*/.*' 2>/dev/null | sort
  fi
done
