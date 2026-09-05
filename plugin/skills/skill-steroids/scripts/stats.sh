#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INVENTORY="$ROOT/scripts/skill-inventory.sh"
GOVERN="$ROOT/scripts/govern-check.sh"

MODE="library"
if [[ "${1:-}" == "--pack" ]]; then
  MODE="pack"
elif [[ -n "${1:-}" && "${1:-}" != "--library" ]]; then
  echo "Usage: stats.sh [--library|--pack]" >&2
  exit 2
fi

echo "SkillSteroids Library Stats"
echo "========================="

INV_OUT="$("$INVENTORY" "--$MODE")"
echo "$INV_OUT" | grep '^#' || true

SKILLS="$(echo "$INV_OUT" | grep 'SKILL.md$' || true)"
TOTAL="$(echo "$SKILLS" | grep -c 'SKILL.md' || true)"
echo "Skills found: $TOTAL"
echo ""

VIOLATIONS=0
CHECKED=0
LISTED=0
LIST_CAP=20
while IFS= read -r skill; do
  [[ -z "$skill" ]] && continue
  CHECKED=$((CHECKED + 1))
  ORCH_FLAG=""
  skill_dir="$(basename "$(dirname "$skill")")"
  if [[ "$skill_dir" == "orchestrator" ]]; then
    ORCH_FLAG="--orchestrator"
  fi
  if ! gov_out="$("$GOVERN" "$skill" $ORCH_FLAG 2>&1)"; then
    VIOLATIONS=$((VIOLATIONS + 1))
    reason="$(echo "$gov_out" | awk '/FAIL / { sub(/^[[:space:]]+/, ""); print; exit }')"
    if [[ "$LISTED" -lt "$LIST_CAP" ]]; then
      echo "⚠ $skill_dir: ${reason:-structural violation}"
      LISTED=$((LISTED + 1))
    fi
  fi
done <<< "$SKILLS"

if [[ "$VIOLATIONS" -gt "$LIST_CAP" ]]; then
  echo "⚠ … $((VIOLATIONS - LIST_CAP)) more with structural violations"
fi

HEALTH=100
if [[ "$CHECKED" -gt 0 ]]; then
  HEALTH=$(( (CHECKED - VIOLATIONS) * 100 / CHECKED ))
fi

# Count open gaps from last run artifact if present.
# Runs now live in the invoking project at .skill-steroids/; fall back to
# legacy pack-local path for older runs.
GAPS=0
BLOCKS=0
PROJECT_ROOT="${SKILL_STEROIDS_PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
LAST_RUN="$PROJECT_ROOT/.skill-steroids/last-run.md"
if [[ ! -f "$LAST_RUN" ]]; then
  LAST_RUN="$ROOT/references/lineage/last-run.md"
fi
if [[ -f "$LAST_RUN" ]]; then
  RUN_FILE="$(awk '/^\*\*Artifact:\*\*/ {gsub(/^\*\*Artifact:\*\* /,""); print}' "$LAST_RUN" | head -1)"
  if [[ -n "$RUN_FILE" ]]; then
    LAST_RUN_DIR="$(dirname "$LAST_RUN")"
    if [[ "$LAST_RUN_DIR" == *".skill-steroids"* ]]; then
      RESOLVE_BASE="$PROJECT_ROOT"
    else
      RESOLVE_BASE="$ROOT"
    fi
    if [[ -f "$RESOLVE_BASE/$RUN_FILE" ]]; then
      GAPS=$(grep -c '| gap |' "$RESOLVE_BASE/$RUN_FILE" 2>/dev/null || true)
      BLOCKS=$(grep -c '\*\*Result:\*\* BLOCK' "$RESOLVE_BASE/$RUN_FILE" 2>/dev/null || true)
    fi
  fi
fi

echo ""
echo "Structural health: ${HEALTH}% ($((CHECKED - VIOLATIONS))/$CHECKED pass govern-check)"
echo "Open gaps (last run): $GAPS"
echo "Unresolved BLOCKs (last run): $BLOCKS"
echo ""
echo "Headline: $TOTAL skills | ${HEALTH}% structural | $GAPS gaps | $BLOCKS BLOCKs"
echo ""
echo "Note: structural health measures format compliance (P-02/P-03/P-05), not usefulness."
echo "Default scan is your unique user library. Use --pack for this plugin only."
echo "Run 'skill steroids audit' for gap analysis."
