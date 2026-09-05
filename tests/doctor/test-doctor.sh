#!/usr/bin/env bash
# Doctor must PASS without ~/.cursor/skills/skill-steroids (marketplace / pack checkout).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DOCTOR="$REPO_ROOT/plugin/skills/skill-steroids/scripts/doctor.sh"
TMPHOME="$(mktemp -d)"
trap 'rm -rf "$TMPHOME"' EXIT

FAILURES=0
pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }

run_doctor() {
  env -u CI -u CURSOR_PLUGIN_ROOT -u CLAUDE_PLUGIN_ROOT -u PLUGIN_ROOT \
    HOME="$TMPHOME" "$DOCTOR"
}

echo "SkillSteroids doctor install-detection tests"

if out="$(run_doctor 2>&1)"; then
  if echo "$out" | grep -q 'Doctor: PASS'; then
    pass "PASS with empty HOME and no plugin-root env"
  else
    fail "exit 0 but missing Doctor: PASS"
    echo "$out" | sed 's/^/    /'
  fi
  if echo "$out" | grep -q 'Cursor symlink not found (optional'; then
    pass "symlink reported as optional"
  else
    fail "expected optional-symlink INFO line"
    echo "$out" | sed 's/^/    /'
  fi
else
  fail "doctor exited non-zero without Cursor symlink"
  echo "$out" | sed 's/^/    /'
fi

if out="$(HOME="$TMPHOME" CURSOR_PLUGIN_ROOT="$TMPHOME/plugin" "$DOCTOR" 2>&1)" \
  && echo "$out" | grep -q 'Plugin root present'; then
  pass "PASS when CURSOR_PLUGIN_ROOT is set"
else
  fail "plugin-root env should PASS"
  echo "${out:-}" | sed 's/^/    /'
fi

if [[ "$FAILURES" -gt 0 ]]; then
  echo "STATUS: FAILED ($FAILURES)"
  exit 1
fi
echo "STATUS: PASSED"
