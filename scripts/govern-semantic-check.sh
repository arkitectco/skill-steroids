#!/usr/bin/env bash
# Heuristic semantic checks mirroring Governor P-01, P-04, P-06.
# Agent Governor remains authoritative for edge cases; this catches regressions.
set -euo pipefail

TARGET="${1:?Usage: govern-semantic-check.sh <file.md> [--change-type create|modify|merge|prune]}"
CHANGE_TYPE="modify"
shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --change-type)
      CHANGE_TYPE="${2:-modify}"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

FAIL=0

pass() { echo "  PASS $1"; }
fail() { echo "  FAIL $1: $2"; FAIL=1; }

CONTENT="$(cat "$TARGET")"
BODY="$(awk 'BEGIN{p=0;c=0} /^---$/{c++; if(c>=2){p=1; next}} p{print}' "$TARGET" 2>/dev/null || cat "$TARGET")"
DESC="$(awk '/^description:/ {
  sub(/^description:[[:space:]]*/, "");
  gsub(/^["'\''"]|["'\''"]$/, "");
  print; exit
}' "$TARGET")"

# P-01: Single responsibility — BLOCK if 3+ unrelated domain keywords without router pattern
DOMAIN_KEYWORDS='homelab|kubernetes|swiftui|postgres|figma|marketing|legal|fitness|finance|android|ios|react|python|rust|docker|terraform|aws|gcp|azure|video|audio|email|seo'
DOMAIN_HITS="$(echo "$DESC $BODY" | grep -oiE "$DOMAIN_KEYWORDS" 2>/dev/null | sort -u | wc -l | tr -d ' ' || true)"
if echo "$DESC $BODY" | grep -qiE 'router|route to|delegates? to'; then
  IS_ROUTER=0
else
  IS_ROUTER=1
fi
if [[ "$DOMAIN_HITS" -ge 3 ]] && [[ "$IS_ROUTER" -ne 0 ]]; then
  fail P-01 "detected $DOMAIN_HITS unrelated domain keywords without router pattern"
else
  pass P-01
fi

# P-04: No duplication — BLOCK if embeds skill-architect or destroyer bodies inline
if echo "$BODY" | grep -qiE 'Modular Skill Architect|skill-creator 2\.0|Category-Specific Templates'; then
  fail P-04 "embeds skill-architect template content"
elif echo "$BODY" | grep -qiE 'Skill Review Rubric \(fallback\)|Ruthlessly review|destroyer rubric' && \
     ! echo "$TARGET" | grep -q 'skill-destroyer-rubric'; then
  fail P-04 "embeds skill-destroyer rubric inline"
else
  pass P-04
fi

# P-06: Safe evolution — BLOCK prune/replace without lineage mention
if [[ "$CHANGE_TYPE" == "prune" || "$CHANGE_TYPE" == "merge" ]]; then
  if echo "$CONTENT" | grep -qiE 'lineage|CHANGELOG|archived entry|lesson learned'; then
    pass P-06
  else
    fail P-06 "prune/merge proposal missing lineage plan"
  fi
else
  pass P-06
fi

exit "$FAIL"
