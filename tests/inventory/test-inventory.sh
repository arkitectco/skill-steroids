#!/usr/bin/env bash
# Inventory must unique-by-realpath across duplicated agent skill roots.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
INV="$REPO_ROOT/plugin/skills/skill-steroids/scripts/skill-inventory.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/real/demo-skill" "$TMP/cursor" "$TMP/agents"
cat > "$TMP/real/demo-skill/SKILL.md" <<'EOF'
---
name: demo-skill
description: Demo skill for inventory dedupe tests. Use when running inventory tests.
---
# Demo
EOF
ln -sfn "$TMP/real/demo-skill" "$TMP/cursor/demo-skill"
ln -sfn "$TMP/real/demo-skill" "$TMP/agents/demo-skill"

FAILURES=0
pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }

out="$(
  HOME="$TMP" \
  SKILL_STEROIDS_CURSOR_SKILLS="$TMP/cursor" \
  SKILL_STEROIDS_AGENTS_SKILLS="$TMP/agents" \
  SKILL_STEROIDS_CLAUDE_SKILLS="$TMP/missing" \
  "$INV" --library
)"

count="$(echo "$out" | grep -c '/SKILL.md$' || true)"
if [[ "$count" -eq 1 ]]; then
  pass "library scan dedupes the same SKILL.md across two roots"
else
  fail "expected 1 unique SKILL.md, got $count"
  echo "$out" | sed 's/^/    /'
fi

pack_out="$("$INV" --pack)"
if echo "$pack_out" | grep -q 'plugin/skills/skill-steroids/SKILL.md$'; then
  pass "--pack includes this plugin's root SKILL.md"
else
  fail "--pack missing plugin SKILL.md"
  echo "$pack_out" | sed 's/^/    /'
fi

if [[ "$FAILURES" -gt 0 ]]; then
  echo "STATUS: FAILED ($FAILURES)"
  exit 1
fi
echo "STATUS: PASSED"
