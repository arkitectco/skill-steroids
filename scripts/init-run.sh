#!/usr/bin/env bash
# Create a new Skill Botox run artifact.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNS="$ROOT/references/runs"
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
# Skill Botox Run
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

# Update last-run pointer
cat > "$ROOT/references/lineage/last-run.md" <<EOF
# Last Run

**Run ID:** $RUN_ID
**Mode:** $MODE
**Scope:** $SCOPE
**Artifact:** references/runs/$RUN_ID.md
**Started:** $(date -Iseconds)
EOF

echo "$OUT"
