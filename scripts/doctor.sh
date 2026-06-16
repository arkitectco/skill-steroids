#!/usr/bin/env bash
# Verify Skill Botox install and recommended dependencies.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

check() {
  local label="$1"
  local path="$2"
  local required="${3:-1}"
  if [[ -e "$path" ]]; then
    echo "✓ $label: $path"
  elif [[ "$required" -eq 1 ]]; then
    echo "✗ $label: MISSING ($path)"
    FAIL=1
  else
    echo "ℹ $label: not found ($path) — optional"
  fi
}

echo "Skill Botox Doctor"
echo "=================="
echo "Pack root: $ROOT"
echo ""

check "Root SKILL.md" "$ROOT/SKILL.md"
check "Governor" "$ROOT/governor/SKILL.md"
check "Orchestrator" "$ROOT/orchestrator/SKILL.md"
check "Principles" "$ROOT/principles.md"
check "Eval runner" "$ROOT/evals/run-eval.sh"
check "skill-architect (recommended)" "$HOME/.agents/skills/skill-architect/SKILL.md" 0

if [[ "${CI:-}" == "true" ]]; then
  echo "ℹ CI mode: skipping Cursor install check"
elif [[ -L "$HOME/.cursor/skills/skill-botox" ]] || [[ -d "$HOME/.cursor/skills/skill-botox" ]]; then
  echo "✓ Cursor install: ~/.cursor/skills/skill-botox"
else
  echo "✗ Cursor install: not found (run ./install.sh)"
  FAIL=1
fi

if [[ -x "$ROOT/scripts/skill-inventory.sh" ]]; then
  COUNT="$("$ROOT/scripts/skill-inventory.sh" 2>/dev/null | grep '/SKILL.md$' | wc -l | tr -d ' ')"
  echo "ℹ Skills discovered: $COUNT"
fi

echo ""
if [[ "$FAIL" -eq 0 ]]; then
  echo "Doctor: PASS"
  exit 0
else
  echo "Doctor: FAIL (see above)"
  exit 1
fi
