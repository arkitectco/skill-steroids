#!/usr/bin/env bash
# Verify SkillSteroids install and recommended dependencies.
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# Walk up from SCRIPT_DIR until evals/run-eval.sh exists (checkout or install symlink).
REPO_ROOT=""
_dir="$SCRIPT_DIR"
while [[ -n "$_dir" && "$_dir" != "/" ]]; do
  if [[ -f "$_dir/evals/run-eval.sh" ]]; then
    REPO_ROOT="$_dir"
    break
  fi
  _parent="$(cd "$_dir/.." && pwd)"
  [[ "$_parent" == "$_dir" ]] && break
  _dir="$_parent"
done
unset _dir _parent
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

echo "SkillSteroids Doctor"
echo "=================="
echo "Pack root: $ROOT"
echo ""

check "Root SKILL.md" "$ROOT/SKILL.md"
check "Governor" "$ROOT/governor/SKILL.md"
check "Orchestrator" "$ROOT/orchestrator/SKILL.md"
check "Principles" "$ROOT/principles.md"
check "Eval runner (used by Experimenter only)" "$REPO_ROOT/evals/run-eval.sh" 0
check "skill-architect (recommended)" "$HOME/.agents/skills/skill-architect/SKILL.md" 0

if [[ -f "$ROOT/using-skill-steroids/SKILL.md" ]]; then
  echo "✓ Bootstrap: $ROOT/using-skill-steroids/SKILL.md"
else
  echo "⚠ Bootstrap skill missing (plugin hooks will inject nothing useful)"
fi

if [[ "${CI:-}" == "true" ]]; then
  echo "ℹ CI mode: skipping Cursor install check"
elif [[ -L "$HOME/.cursor/skills/skill-steroids" ]] || [[ -d "$HOME/.cursor/skills/skill-steroids" ]]; then
  echo "✓ Cursor install: ~/.cursor/skills/skill-steroids"
else
  echo "✗ Cursor install: not found (run ./install.sh)"
  FAIL=1
fi

if [[ -x "$ROOT/scripts/skill-inventory.sh" ]]; then
  COUNT="$("$ROOT/scripts/skill-inventory.sh" 2>/dev/null | grep -c '/SKILL.md$' || true)"
  echo "ℹ Skills discovered: ${COUNT:-0}"
fi

echo ""
if [[ "$FAIL" -eq 0 ]]; then
  echo "Doctor: PASS"
  exit 0
else
  echo "Doctor: FAIL (see above)"
  exit 1
fi
