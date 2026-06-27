#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PACK_ROOT="$REPO_ROOT/packages/skill-pack"
HOOK="$PACK_ROOT/hooks/session-start"
CODEX_HOOK="$PACK_ROOT/hooks/session-start-codex"
WRAPPER="$PACK_ROOT/hooks/run-hook.cmd"

FAILURES=0

pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }

assert_hook_output() {
  local description="$1"
  local shape="$2"
  local contains="$3"
  shift 3
  local output
  if ! output="$(env -i PATH="${PATH:-}" HOME="${HOME:-/tmp}" "$@" 2>&1)"; then
    fail "$description"
    return
  fi
  if ! printf '%s' "$output" | \
    EXPECT_SHAPE="$shape" EXPECT_CONTAINS="$contains" node -e '
const fs = require("fs");
const payload = JSON.parse(fs.readFileSync(0, "utf8"));
const shape = process.env.EXPECT_SHAPE;
let ctx;
if (shape === "cursor") {
  if (!payload.additional_context) process.exit(1);
  ctx = payload.additional_context;
} else if (shape === "nested") {
  ctx = payload.hookSpecificOutput?.additionalContext;
  if (!ctx) process.exit(1);
} else process.exit(1);
if (!ctx.includes(process.env.EXPECT_CONTAINS)) process.exit(1);
'; then
    fail "$description"
  else
    pass "$description"
  fi
}

echo "SkillSteroids SessionStart hook tests"

assert_hook_output \
  "Cursor emits additional_context with audit trigger" \
  "cursor" \
  "skill steroids audit" \
  CURSOR_PLUGIN_ROOT="$PACK_ROOT" bash "$HOOK"

assert_hook_output \
  "Claude emits nested SessionStart context" \
  "nested" \
  "EXTREMELY_IMPORTANT" \
  CLAUDE_PLUGIN_ROOT="$PACK_ROOT" bash "$HOOK"

assert_hook_output \
  "Codex dedicated script emits nested context" \
  "nested" \
  "using-skill-steroids" \
  PLUGIN_ROOT="$PACK_ROOT" bash "$CODEX_HOOK"

assert_hook_output \
  "Wrapper dispatches session-start-codex" \
  "nested" \
  "SkillSteroids" \
  PLUGIN_ROOT="$PACK_ROOT" bash "$WRAPPER" session-start-codex

if [[ "$FAILURES" -gt 0 ]]; then
  echo "STATUS: FAILED ($FAILURES)"
  exit 1
fi
echo "STATUS: PASSED"
