#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GOVERN="$ROOT/scripts/govern-check.sh"
FAILURES=0
TOTAL=0

echo "Skill Botox Eval Harness"
echo "========================"

rule_result() {
  local out="$1"
  local rule="$2"
  if echo "$out" | grep -E "PASS $rule" >/dev/null; then
    echo pass
  else
    echo fail
  fi
}

assert_fixture() {
  local path="$1"
  local rule="$2"
  local want="$3"
  local extra="${4:-}"
  local full="$ROOT/$path"

  TOTAL=$((TOTAL + 1))

  if [[ ! -f "$full" ]]; then
    echo "✗ MISSING $path"
    FAILURES=$((FAILURES + 1))
    return
  fi

  local out
  out="$("$GOVERN" "$full" $extra 2>&1 || true)"
  local got
  got="$(rule_result "$out" "$rule")"

  if [[ "$got" == "$want" ]]; then
    echo "✓ $path [$rule] expected=$want"
  else
    echo "✗ $path [$rule] expected=$want got=$got"
    echo "$out" | sed 's/^/    /'
    FAILURES=$((FAILURES + 1))
  fi
}

assert_fixture "evals/golden-pass/minimal-skill/SKILL.md" P-02 pass
assert_fixture "evals/golden-pass/minimal-skill/SKILL.md" P-03 pass
assert_fixture "evals/golden-pass/minimal-skill/SKILL.md" P-05 pass

assert_fixture "evals/golden-violations/short-desc/SKILL.md" P-02 fail
assert_fixture "evals/golden-violations/bloated/SKILL.md" P-03 fail
assert_fixture "evals/golden-violations/missing-io/SKILL.md" P-05 fail "--orchestrator"

echo ""
if [[ "$FAILURES" -eq 0 ]]; then
  echo "Eval harness: PASS ($TOTAL/$TOTAL)"
  exit 0
else
  echo "Eval harness: FAIL ($FAILURES/$TOTAL mismatches)"
  exit 1
fi
