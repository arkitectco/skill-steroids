#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INVENTORY="$ROOT/scripts/skill-inventory.sh"
GOVERN="$ROOT/scripts/govern-check.sh"

echo "Skill Botox Library Stats"
echo "========================="

SKILLS="$("$INVENTORY" 2>/dev/null | grep 'SKILL.md$' || true)"
TOTAL="$(echo "$SKILLS" | grep -c 'SKILL.md' || true)"
echo "Skills found: $TOTAL"
echo ""

VIOLATIONS=0
CHECKED=0
while IFS= read -r skill; do
  [[ -z "$skill" ]] && continue
  CHECKED=$((CHECKED + 1))
  ORCH_FLAG=""
  if grep -qi orchestrator <<< "$skill"; then
    ORCH_FLAG="--orchestrator"
  fi
  if ! "$GOVERN" "$skill" $ORCH_FLAG >/dev/null 2>&1; then
    VIOLATIONS=$((VIOLATIONS + 1))
    echo "⚠ $(basename "$(dirname "$skill")"): structural violation"
  fi
done <<< "$SKILLS"

HEALTH=100
if [[ "$CHECKED" -gt 0 ]]; then
  HEALTH=$(( (CHECKED - VIOLATIONS) * 100 / CHECKED ))
fi

echo ""
echo "Structural health: ${HEALTH}% ($((CHECKED - VIOLATIONS))/$CHECKED pass govern-check)"
echo "Headline: scan complete — $TOTAL skills, ${HEALTH}% structural pass rate"
