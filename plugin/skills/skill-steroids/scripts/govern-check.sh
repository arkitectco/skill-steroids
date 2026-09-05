#!/usr/bin/env bash
# Deterministic structural checks mirroring Governor P-02, P-03, P-05.
set -euo pipefail

SKILL_FILE="${1:?Usage: govern-check.sh <SKILL.md> [--orchestrator]}"
ORCHESTRATOR=0
[[ "${2:-}" == "--orchestrator" ]] && ORCHESTRATOR=1

FAIL=0

pass() { echo "  PASS $1"; }
fail() { echo "  FAIL $1: $2"; FAIL=1; }

# P-02: description length and a situation/trigger cue.
# Folded/literal YAML (`description: >-` / `|`) continues on indented lines.
# Cue is not a literal "WHEN" — "use for", "use this skill when", "trigger:", quoted phrases all count.
DESC="$(awk '
  function trim(s) {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", s)
    return s
  }
  /^---$/ {
    if (in_fm == 0) { in_fm = 1; next }
    if (fold && acc != "") print acc
    exit
  }
  in_fm && fold {
    if ($0 ~ /^[A-Za-z0-9_-]+:[[:space:]]/) {
      print acc
      exit
    }
    line = trim($0)
    if (line == "") next
    if (acc != "") acc = acc " "
    acc = acc line
    next
  }
  in_fm && /^description:[[:space:]]*[>|][+-]?[[:space:]]*$/ {
    fold = 1
    next
  }
  in_fm && /^description:[[:space:]]*/ {
    sub(/^description:[[:space:]]*/, "")
    gsub(/^["'\'']|["'\'']$/, "")
    print
    exit
  }
  END {
    if (fold && acc != "") print acc
  }
' "$SKILL_FILE")"
DESC_LEN=${#DESC}
if [[ "$DESC_LEN" -lt 20 ]]; then
  fail P-02 "description under 20 chars ($DESC_LEN)"
elif ! echo "$DESC" | grep -qiE 'when(ever)?|use[[:space:]]+(for|to|during|this|only)|triggers?:|trigger[[:space:]]+on|\binvoke|\basked[[:space:]]+to|"[^"]{6,}"'; then
  fail P-02 "description has no situation cue (when / use for / trigger / quoted phrase)"
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
