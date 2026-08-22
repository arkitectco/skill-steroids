#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACK_ROOT="$REPO_ROOT/plugin/skills/skill-steroids"
SEMANTIC="$PACK_ROOT/scripts/govern-semantic-check.sh"
FAILURES=0
TOTAL=0

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
  shift 3
  local full="$REPO_ROOT/$path"

  TOTAL=$((TOTAL + 1))

  if [[ ! -f "$full" ]]; then
    echo "✗ MISSING $path"
    FAILURES=$((FAILURES + 1))
    return
  fi

  local out
  out="$("$SEMANTIC" "$full" "$@" 2>&1 || true)"
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

assert_fixture "evals/golden-proposals/monolithic-homelab.md" P-01 fail
assert_fixture "evals/golden-proposals/monolithic-homelab.md" P-04 pass
assert_fixture "evals/golden-proposals/monolithic-homelab.md" P-06 pass

assert_fixture "evals/golden-proposals/duplicate-architect.md" P-01 pass
assert_fixture "evals/golden-proposals/duplicate-architect.md" P-04 fail
assert_fixture "evals/golden-proposals/duplicate-architect.md" P-06 pass

assert_fixture "evals/golden-proposals/clean-evolve.md" P-01 pass
assert_fixture "evals/golden-proposals/clean-evolve.md" P-04 pass
assert_fixture "evals/golden-proposals/clean-evolve.md" P-06 pass

assert_fixture "evals/golden-proposals/prune-no-lineage.md" P-01 pass --change-type prune
assert_fixture "evals/golden-proposals/prune-no-lineage.md" P-04 pass --change-type prune
assert_fixture "evals/golden-proposals/prune-no-lineage.md" P-06 fail --change-type prune

assert_fixture "evals/golden-proposals/router-ok.md" P-01 pass
assert_fixture "evals/golden-proposals/router-ok.md" P-04 pass
assert_fixture "evals/golden-proposals/router-ok.md" P-06 pass

echo ""
if [[ "$FAILURES" -eq 0 ]]; then
  echo "Semantic eval harness: PASS ($TOTAL/$TOTAL)"
  exit 0
else
  echo "Semantic eval harness: FAIL ($FAILURES/$TOTAL mismatches)"
  exit 1
fi
