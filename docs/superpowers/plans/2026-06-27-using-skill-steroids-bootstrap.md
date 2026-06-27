# Using SkillSteroids Session Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Inject a lightweight `using-skill-steroids` bootstrap on every SessionStart (Cursor, Claude, Codex) so agents know when to invoke the full SkillSteroids framework, without auto-running audit/mutate loops.

**Architecture:** All bootstrap and hook files live inside `packages/skill-pack/`. SessionStart hooks read `using-skill-steroids/SKILL.md` and inject it into context (Superpowers 6.0.3 pattern). Thin plugin manifests at repo root gain a `hooks` field pointing at pack hook JSON. Root `SKILL.md` stays `disable-model-invocation: true`.

**Tech Stack:** bash, jq, JSON hook manifests, node (hook test JSON parsing only)

## Global Constraints

- Bootstrap + hooks live only in `packages/skill-pack/` — no duplicate hook trees at repo root
- Root `packages/skill-pack/SKILL.md` keeps `disable-model-invocation: true` — do not change orchestrator logic
- Bootstrap content: triggers + friction nudge + one-line when-NOT-to-invoke — no orchestrator/Governor duplication
- Platforms: Cursor + Claude Code + Codex hooks in one release
- Unified version **2.3.0** via `scripts/bump-plugin-version.sh`
- Plugin artifacts must NOT include `apps/web/`, `evals/`, or `node_modules`
- Post-turn hooks out of scope — friction nudge is bootstrap text only
- Preserve doctor + eval harness PASS — no regressions
- Codex sync picks up hooks automatically (pack-only rsync) — verify in dry-run, no monorepo paths

---

## File Map

| Path | Responsibility |
|------|----------------|
| `packages/skill-pack/using-skill-steroids/SKILL.md` | Lightweight session bootstrap content |
| `packages/skill-pack/hooks/session-start` | Cursor + Claude SessionStart injection |
| `packages/skill-pack/hooks/session-start-codex` | Codex SessionStart injection |
| `packages/skill-pack/hooks/run-hook.cmd` | Cross-platform hook wrapper |
| `packages/skill-pack/hooks/hooks-cursor.json` | Cursor hook manifest |
| `packages/skill-pack/hooks/hooks.json` | Claude hook manifest |
| `packages/skill-pack/hooks/hooks-codex.json` | Codex hook manifest |
| `tests/hooks/test-session-start.sh` | Hook output smoke tests |
| `.cursor-plugin/plugin.json` | Add `hooks` field |
| `.claude-plugin/plugin.json` | Add `hooks` field |
| `.codex-plugin/plugin.json` | Add `hooks` field |
| `scripts/verify-plugin-manifests.sh` | Validate hooks + bootstrap |
| `.github/workflows/evals.yml` | Add hook test CI step |
| `CHANGELOG.md`, `INSTALL.md`, `README.md`, `docs/PUBLISHING.md` | Doc updates |

---

### Task 1: Bootstrap skill

**Files:**
- Create: `packages/skill-pack/using-skill-steroids/SKILL.md`

**Interfaces:**
- Produces: bootstrap markdown consumed by `session-start` at `${PLUGIN_ROOT}/using-skill-steroids/SKILL.md` where `PLUGIN_ROOT` = parent of `hooks/`

- [ ] **Step 1: Create bootstrap skill**

Create `packages/skill-pack/using-skill-steroids/SKILL.md`:

```markdown
---
name: using-skill-steroids
description: Establishes when and how to invoke SkillSteroids for skill library audit or mutation. Injected at session start via plugin hook — not for manual file reads.
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute an unrelated task, skip this skill.
</SUBAGENT-STOP>

# Using SkillSteroids

Session orientation only. This is **not** the full audit/mutate framework.

## Purpose

SkillSteroids governs evolution of your AI agent skill library. Load the full `skill-steroids` skill only when the user asks for library audit or mutation — never for normal coding tasks.

## When to invoke `skill-steroids`

| User intent | Example phrases | Mode |
|-------------|-------------------|------|
| Health report | "run skill steroids", "skill steroids audit", "skill library health" | audit |
| Governed change | "skill steroids mutate", "evolve skill X" | mutate |

## When NOT to invoke

Normal feature work, bug fixes, refactors, and general coding are **not** skill library evolution. Do not load `skill-steroids` unless the user clearly wants skill-library audit or mutation.

## How to invoke

Use your platform's skill-loading mechanism to load **`skill-steroids`**. Do not manually read orchestrator, governor, or evolver files with file tools.

## Post-session friction nudge

After completing a multi-step task (3+ tool calls or 1+ file writes), if skill friction occurred — wrong skill loaded, repeated explanations, manual overrides — **suggest** (do not auto-run):

> Run **"skill steroids audit"** and share 1–3 friction bullets.

This is a gentle reminder only. Never start the audit loop without an explicit user request.
```

- [ ] **Step 2: Verify file exists**

```bash
test -f packages/skill-pack/using-skill-steroids/SKILL.md
grep -q 'skill steroids audit' packages/skill-pack/using-skill-steroids/SKILL.md
grep -q 'SUBAGENT-STOP' packages/skill-pack/using-skill-steroids/SKILL.md
echo "Bootstrap skill: OK"
```

- [ ] **Step 3: Commit**

```bash
git add packages/skill-pack/using-skill-steroids/SKILL.md
git commit -m "feat: add using-skill-steroids session bootstrap skill"
```

---

### Task 2: SessionStart hooks + tests

**Files:**
- Create: `packages/skill-pack/hooks/run-hook.cmd`
- Create: `packages/skill-pack/hooks/session-start`
- Create: `packages/skill-pack/hooks/session-start-codex`
- Create: `packages/skill-pack/hooks/hooks-cursor.json`
- Create: `packages/skill-pack/hooks/hooks.json`
- Create: `packages/skill-pack/hooks/hooks-codex.json`
- Create: `tests/hooks/test-session-start.sh`

**Interfaces:**
- Consumes: `packages/skill-pack/using-skill-steroids/SKILL.md` (Task 1)
- Produces: hook scripts executable; test script exits 0 when injection contains `skill steroids audit` and `<EXTREMELY_IMPORTANT>`

- [ ] **Step 1: Write the failing hook test**

Create `tests/hooks/test-session-start.sh`:

```bash
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
```

```bash
chmod +x tests/hooks/test-session-start.sh
```

- [ ] **Step 2: Run test to verify it fails**

```bash
./tests/hooks/test-session-start.sh
```

Expected: FAIL — hook scripts not found

- [ ] **Step 3: Create hook scripts**

Create `packages/skill-pack/hooks/run-hook.cmd` — copy verbatim from Superpowers 6.0.3 `hooks/run-hook.cmd`.

Create `packages/skill-pack/hooks/session-start`:

```bash
#!/usr/bin/env bash
# SessionStart hook for SkillSteroids plugin

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

bootstrap_content=$(cat "${PLUGIN_ROOT}/using-skill-steroids/SKILL.md" 2>&1 || echo "Error reading using-skill-steroids skill")

escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

bootstrap_escaped=$(escape_for_json "$bootstrap_content")
session_context="<EXTREMELY_IMPORTANT>\nYou have SkillSteroids installed.\n\n**Below is your using-skill-steroids bootstrap — when to invoke the full framework. Load skill-steroids only when the user asks for audit or mutation:**\n\n${bootstrap_escaped}\n</EXTREMELY_IMPORTANT>"

if [ -n "${CURSOR_PLUGIN_ROOT:-}" ]; then
  printf '{\n  "additional_context": "%s"\n}\n' "$session_context" | cat
elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -z "${COPILOT_CLI:-}" ]; then
  printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$session_context" | cat
else
  printf '{\n  "additionalContext": "%s"\n}\n' "$session_context" | cat
fi

exit 0
```

Create `packages/skill-pack/hooks/session-start-codex`:

```bash
#!/usr/bin/env bash
# Codex SessionStart hook for SkillSteroids plugin

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

bootstrap_content=$(cat "${PLUGIN_ROOT}/using-skill-steroids/SKILL.md" 2>&1 || echo "Error reading using-skill-steroids skill")

escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

bootstrap_escaped=$(escape_for_json "$bootstrap_content")
session_context="<EXTREMELY_IMPORTANT>\nYou have SkillSteroids installed.\n\n**Below is your using-skill-steroids bootstrap — when to invoke the full framework. Load skill-steroids only when the user asks for audit or mutation:**\n\n${bootstrap_escaped}\n</EXTREMELY_IMPORTANT>"

printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$session_context" | cat

exit 0
```

Create hook JSON manifests:

`packages/skill-pack/hooks/hooks-cursor.json`:

```json
{
  "version": 1,
  "hooks": {
    "sessionStart": [
      {
        "command": "./run-hook.cmd session-start"
      }
    ]
  }
}
```

`packages/skill-pack/hooks/hooks.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/../packages/skill-pack/hooks/run-hook.cmd\" session-start",
            "async": false
          }
        ]
      }
    ]
  }
}
```

`packages/skill-pack/hooks/hooks-codex.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear",
        "hooks": [
          {
            "type": "command",
            "command": "\"${PLUGIN_ROOT}/hooks/run-hook.cmd\" session-start-codex",
            "async": false
          }
        ]
      }
    ]
  }
}
```

Note: After Codex sync flattens pack to plugin root, `PLUGIN_ROOT/hooks/` resolves correctly. Monorepo Claude path uses `${CLAUDE_PLUGIN_ROOT}/../packages/skill-pack/hooks/`.

```bash
chmod +x packages/skill-pack/hooks/session-start \
         packages/skill-pack/hooks/session-start-codex \
         packages/skill-pack/hooks/run-hook.cmd
```

- [ ] **Step 4: Run test to verify it passes**

```bash
./tests/hooks/test-session-start.sh
```

Expected: `STATUS: PASSED`

- [ ] **Step 5: Commit**

```bash
git add packages/skill-pack/hooks/ tests/hooks/test-session-start.sh
git commit -m "feat: add SessionStart hooks for Cursor, Claude, and Codex"
```

---

### Task 3: Plugin manifest wiring + verify script

**Files:**
- Modify: `.cursor-plugin/plugin.json`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.codex-plugin/plugin.json`
- Modify: `scripts/verify-plugin-manifests.sh`
- Modify: `.github/workflows/evals.yml`

**Interfaces:**
- Consumes: hook JSON files at `packages/skill-pack/hooks/` (Task 2)
- Produces: all three manifests have `hooks` field; verify script checks hooks resolve

- [ ] **Step 1: Add hooks field to Cursor manifest**

Add to `.cursor-plugin/plugin.json` (after `skills` line):

```json
  "hooks": "../packages/skill-pack/hooks/hooks-cursor.json"
```

- [ ] **Step 2: Add hooks field to Claude manifest**

Add to `.claude-plugin/plugin.json`:

```json
  "hooks": "../packages/skill-pack/hooks/hooks.json"
```

- [ ] **Step 3: Add hooks field to Codex manifest**

Add to `.codex-plugin/plugin.json`:

```json
  "hooks": "../packages/skill-pack/hooks/hooks-codex.json"
```

- [ ] **Step 4: Extend verify-plugin-manifests.sh**

Add after `check_manifest` function definition, before manifest checks:

```bash
check_hooks() {
  local label="$1"
  local manifest="$2"
  local hooks_rel
  hooks_rel="$(jq -r '.hooks // empty' "$manifest")"
  if [[ -z "$hooks_rel" ]]; then
    echo "✗ $label: missing hooks field"
    FAIL=1
    return
  fi
  local hooks_file
  hooks_file="$(cd "$(dirname "$manifest")" && cd "$hooks_rel" && pwd)"
  if [[ -f "$hooks_file" ]]; then
    echo "✓ $label hooks → $hooks_file"
  else
    echo "✗ $label: hooks not found at $hooks_file"
    FAIL=1
  fi
}

PACK="$ROOT/packages/skill-pack"
if [[ -f "$PACK/using-skill-steroids/SKILL.md" ]]; then
  echo "✓ bootstrap → $PACK/using-skill-steroids/SKILL.md"
else
  echo "✗ bootstrap skill missing"
  FAIL=1
fi
```

After existing `check_manifest` calls, add:

```bash
check_hooks "Cursor" "$ROOT/.cursor-plugin/plugin.json"
check_hooks "Claude" "$ROOT/.claude-plugin/plugin.json"
check_hooks "Codex" "$ROOT/.codex-plugin/plugin.json"
```

- [ ] **Step 5: Add CI step**

In `.github/workflows/evals.yml`, after the verify plugin manifests step:

```yaml
      - name: Test SessionStart hooks
        run: ./tests/hooks/test-session-start.sh
```

- [ ] **Step 6: Run verification**

```bash
./scripts/verify-plugin-manifests.sh
./tests/hooks/test-session-start.sh
```

Expected: both PASS

- [ ] **Step 7: Commit**

```bash
git add .cursor-plugin/plugin.json .claude-plugin/plugin.json .codex-plugin/plugin.json \
        scripts/verify-plugin-manifests.sh .github/workflows/evals.yml
git commit -m "feat: wire plugin manifests to pack SessionStart hooks"
```

---

### Task 4: Version bump + documentation

**Files:**
- Modify: `CHANGELOG.md`, `INSTALL.md`, `README.md`, `docs/PUBLISHING.md`
- Modify: `packages/skill-pack/references/hooks/post-session-reminder.md` (note bootstrap supersedes future hook)

**Interfaces:**
- Consumes: `scripts/bump-plugin-version.sh` (existing)
- Produces: all version fields at **2.3.0**; docs describe bootstrap behavior

- [ ] **Step 1: Bump version to 2.3.0**

```bash
./scripts/bump-plugin-version.sh 2.3.0
./scripts/bump-plugin-version.sh --check
```

Expected: all five files show `2.3.0`, exit 0

- [ ] **Step 2: Prepend CHANGELOG**

Add to `CHANGELOG.md`:

```markdown
## [2.3.0] - 2026-06-27

### Added
- `using-skill-steroids` session bootstrap skill (triggers + friction nudge)
- SessionStart hooks for Cursor, Claude, and Codex (`packages/skill-pack/hooks/`)
- Hook smoke tests (`tests/hooks/test-session-start.sh`)

### Changed
- Plugin manifests include `hooks` field pointing at pack hooks
- Plugin installs inject bootstrap every session; symlink install unchanged
```

- [ ] **Step 3: Update INSTALL.md**

After the plugin install table, add:

```markdown
**Plugin bootstrap:** Cursor, Claude, and Codex plugin installs inject `using-skill-steroids` at session start — agents learn trigger phrases automatically. Symlink install (`./install.sh`) does not inject hooks; optionally paste the bootstrap snippet below into a user rule or `AGENTS.md`.

### Symlink bootstrap snippet (optional)

After multi-step work, if skill friction occurred, suggest: **"skill steroids audit"** with 1–3 friction bullets. Load full `skill-steroids` only when the user asks for audit or mutation.
```

- [ ] **Step 4: Update README.md plugin section**

Add after manifests line:

```markdown
Plugin installs inject `using-skill-steroids` at session start (SessionStart hooks). The full audit/mutate loop runs only when you ask.
```

- [ ] **Step 5: Update docs/PUBLISHING.md**

In the verify section, add:

```markdown
./tests/hooks/test-session-start.sh
```

Add note: hooks ship inside `packages/skill-pack/` and sync to Codex automatically.

- [ ] **Step 6: Update post-session-reminder.md**

Replace the "Cursor Hook (future)" section with:

```markdown
## Session bootstrap (plugin install)

Plugin installs inject the friction nudge via `using-skill-steroids` SessionStart hook. Symlink users can paste the snippet above into a user rule.
```

- [ ] **Step 7: Commit**

```bash
git add CHANGELOG.md INSTALL.md README.md docs/PUBLISHING.md \
        packages/skill-pack/references/hooks/post-session-reminder.md \
        packages/skill-pack/package.json .cursor-plugin/plugin.json \
        .claude-plugin/plugin.json .claude-plugin/marketplace.json \
        .codex-plugin/plugin.json
git commit -m "docs: session bootstrap install docs and bump to 2.3.0"
```

---

### Task 5: Final verification

**Files:**
- Modify: `packages/skill-pack/scripts/doctor.sh` (optional bootstrap check)

**Interfaces:**
- Consumes: all prior tasks

- [ ] **Step 1: Full verification suite**

```bash
./scripts/verify-plugin-manifests.sh
./tests/hooks/test-session-start.sh
CI=true ./packages/skill-pack/scripts/doctor.sh
./evals/run-eval.sh
```

Expected: all PASS

- [ ] **Step 2: Sync dry-run includes hooks**

```bash
TMP=$(mktemp -d) && mkdir -p "$TMP/plugins/skill-steroids"
./scripts/sync-to-codex-plugin.sh -n -y --local "$TMP" 2>&1 | tee /tmp/sync-preview.txt
grep -E 'using-skill-steroids|hooks/session-start' /tmp/sync-preview.txt
grep -E 'apps/web|evals/' /tmp/sync-preview.txt && echo FAIL || echo "Sync source clean"
```

Expected: preview mentions bootstrap/hooks; `Sync source clean`

- [ ] **Step 3: Optional doctor bootstrap check**

Add to `packages/skill-pack/scripts/doctor.sh` after pack root checks:

```bash
if [[ -f "$PACK_ROOT/using-skill-steroids/SKILL.md" ]]; then
  echo "✓ Bootstrap: $PACK_ROOT/using-skill-steroids/SKILL.md"
else
  echo "⚠ Bootstrap skill missing (plugin hooks will inject nothing useful)"
fi
```

Run doctor:

```bash
./packages/skill-pack/scripts/doctor.sh
```

- [ ] **Step 4: Commit**

```bash
git add packages/skill-pack/scripts/doctor.sh
git commit -m "chore: doctor checks using-skill-steroids bootstrap exists"
```

---

## Self-Review Checklist

| Spec requirement | Task |
|------------------|------|
| `using-skill-steroids` bootstrap skill | Task 1 |
| Triggers + friction nudge + when-NOT | Task 1 |
| Six hook files in pack | Task 2 |
| Cursor + Claude + Codex hooks | Task 2, 3 |
| Manifest `hooks` field | Task 3 |
| verify-plugin-manifests extended | Task 3 |
| Hook smoke test | Task 2, CI Task 3 |
| Version 2.3.0 | Task 4 |
| Docs updates | Task 4 |
| Codex sync verification | Task 5 |
| Root SKILL.md unchanged | Global constraint |
| Doctor + evals PASS | Task 5 |

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-06-27-using-skill-steroids-bootstrap.md`. Two execution options:

**1. Subagent-Driven (recommended)** — fresh subagent per task, spec + quality review between tasks

**2. Inline Execution** — execute in this session using executing-plans, batch with checkpoints

Which approach?
