#!/usr/bin/env bash
# Create a new SkillSteroids run artifact.
# Runs persist in the invoking project, not in the pack source tree.
set -euo pipefail

PACK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Resolve the project workspace: explicit override > git root > cwd.
PROJECT_ROOT="${SKILL_STEROIDS_PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
RUNS="$PROJECT_ROOT/.skill-steroids/runs"

MODE="${1:-audit}"
SCOPE="${2:-full}"
RUN_ID="$(date +%Y-%m-%d-%H%M)"
OUT="$RUNS/$RUN_ID.md"

mkdir -p "$RUNS"

if [[ -f "$OUT" ]]; then
  echo "Run file already exists: $OUT" >&2
  exit 1
fi

cat > "$OUT" <<EOF
# SkillSteroids Run
**Run ID:** $RUN_ID
**Mode:** $MODE
**Scope:** $SCOPE
**Status:** initialized

## Observation Report
(pending)

## Analysis Report
(pending)

## Governor Verdicts
(pending)

## Decision
**User approval:** pending
**Approved proposals:** pending

## Act Log
(pending)

## Lineage
(pending)
EOF

# Update last-run pointer (project-local)
mkdir -p "$PROJECT_ROOT/.skill-steroids"
cat > "$PROJECT_ROOT/.skill-steroids/last-run.md" <<EOF
# Last Run

**Run ID:** $RUN_ID
**Mode:** $MODE
**Scope:** $SCOPE
**Artifact:** .skill-steroids/runs/$RUN_ID.md
**Started:** $(date -Iseconds)
EOF

echo "$OUT"
