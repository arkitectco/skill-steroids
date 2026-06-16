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

# Count open gaps from last run artifact if present
GAPS=0
BLOCKS=0
LAST_RUN="$ROOT/references/lineage/last-run.md"
if [[ -f "$LAST_RUN" ]]; then
  RUN_FILE="$(awk '/^\*\*Artifact:\*\*/ {gsub(/^\*\*Artifact:\*\* /,""); print}' "$LAST_RUN" | head -1)"
  if [[ -n "$RUN_FILE" && -f "$ROOT/$RUN_FILE" ]]; then
    GAPS=$(grep -c '| gap |' "$ROOT/$RUN_FILE" 2>/dev/null || true)
    BLOCKS=$(grep -c '\*\*Result:\*\* BLOCK' "$ROOT/$RUN_FILE" 2>/dev/null || true)
  fi
fi

echo ""
echo "Structural health: ${HEALTH}% ($((CHECKED - VIOLATIONS))/$CHECKED pass govern-check)"
echo "Open gaps (last run): $GAPS"
echo "Unresolved BLOCKs (last run): $BLOCKS"
echo ""
echo "Headline: $TOTAL skills | ${HEALTH}% structural | $GAPS gaps | $BLOCKS BLOCKs"
echo ""
echo "Note: structural health measures format compliance, not skill usefulness."
echo "Run 'skill botox audit' for gap analysis."
