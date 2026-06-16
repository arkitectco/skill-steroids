#!/usr/bin/env bash
# Lists SKILL.md files under common skill roots. Read-only.
set -euo pipefail

roots=(
  "$HOME/.cursor/skills"
  "$HOME/.cursor/skills-cursor"
  "$HOME/.agents/skills"
  "$HOME/.claude/skills"
)

for root in "${roots[@]}"; do
  if [[ -d "$root" ]]; then
    echo "=== $root ==="
    local_count="$(find -L "$root" -name 'SKILL.md' 2>/dev/null | wc -l | tr -d ' ')"
    if [[ "$local_count" -eq 0 ]]; then
      echo "(no SKILL.md files found)"
    else
      find -L "$root" -name 'SKILL.md' 2>/dev/null | sort
    fi
  fi
done
