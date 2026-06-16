#!/usr/bin/env bash
# Deterministic structural checks mirroring Governor P-02, P-03, P-05.
set -euo pipefail

SKILL_FILE="${1:?Usage: govern-check.sh <SKILL.md> [--orchestrator]}"
ORCHESTRATOR=0
[[ "${2:-}" == "--orchestrator" ]] && ORCHESTRATOR=1

FAIL=0

pass() { echo "  PASS $1"; }
fail() { echo "  FAIL $1: $2"; FAIL=1; }

# P-02: description length and WHEN triggers
DESC="$(awk '/^description:/ {
  sub(/^description:[[:space:]]*/, "");
  gsub(/^["'\'']|["'\'']$/, "");
  print;
  exit
}' "$SKILL_FILE")"
DESC_LEN=${#DESC}
if [[ "$DESC_LEN" -lt 20 ]]; then
  fail P-02 "description under 20 chars ($DESC_LEN)"
elif ! echo "$DESC" | grep -qiE 'use when|when user|when the user|when working|when asked'; then
  fail P-02 "description missing WHEN trigger phrase"
else
  pass P-02
fi

# P-03: line count
LINES="$(wc -l < "$SKILL_FILE" | tr -d ' ')"
if [[ "$LINES" -gt 500 ]]; then
  fail P-03 "SKILL.md has $LINES lines (>500)"
else
  pass P-03
fi

# P-05: orchestrator-class requires Inputs/Outputs
if [[ "$ORCHESTRATOR" -eq 1 ]]; then
  if grep -qiE '^## Inputs' "$SKILL_FILE" && grep -qiE '^## Outputs' "$SKILL_FILE"; then
    pass P-05
  else
    fail P-05 "missing ## Inputs or ## Outputs"
  fi
else
  pass P-05
fi

exit "$FAIL"
