# Skill Botox Phase B — Audit Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Harden Skill Botox v1 into a provable **audit + governed mutation** workflow — persisted runs, honest metrics, scoped analysis, semantic Governor heuristics, and explicit friction input — addressing the devil's advocate gaps without over-promising a closed-loop meta-OS.

**Architecture:** Keep markdown-first skills as the product core. Add a thin `scripts/` + `evals/` layer for deterministic semantic heuristics (P-01, P-04, P-06) alongside existing structural checks (P-02, P-03, P-05). Introduce `references/runs/<run-id>.md` as the single persisted artifact per orchestrator execution. Reposition orchestrator around two modes: **`audit`** (default, no writes) and **`mutate`** (single approved change). Defer Experimenter from the default loop; replace "weekly automation" with an optional Cursor hook snippet.

**Tech Stack:** Bash (stats, govern-semantic-check, init-run), markdown skills (orchestrator/observer/analyzer), JSON fixtures, GitHub Actions CI.

---

## File Map

| Path | Responsibility |
|------|----------------|
| `scripts/govern-semantic-check.sh` | Deterministic heuristics for P-01, P-04, P-06 on proposal/skill text |
| `scripts/init-run.sh` | Create `references/runs/<run-id>.md` from template |
| `scripts/stats.sh` | Dual headline: structural % + gap/BLOCK counts |
| `evals/golden-proposals/*.md` | 5 proposal fixtures with expected semantic verdicts |
| `evals/expected-semantic-verdicts.json` | Fixture → expected P-01/P-04/P-06 results |
| `evals/run-semantic-eval.sh` | Run semantic golden checks |
| `evals/run-eval.sh` | Invoke structural + semantic eval runners |
| `references/runs/README.md` | Run artifact schema and resume protocol |
| `references/runs/.gitkeep` | Keep directory in git |
| `references/lineage/last-run.md` | Pointer to most recent run (updated by orchestrator) |
| `references/output-schemas.md` | Add Run Artifact schema; evidence column on proposals |
| `references/hooks/post-session-reminder.md` | Optional AGENTS.md / hook snippet (replaces weekly automation claim) |
| `orchestrator/SKILL.md` | audit/mutate modes, doctor gate, caps, run persistence |
| `observer/SKILL.md` | Require explicit friction input; no invented F-xx |
| `analyzer/SKILL.md` | Max 5 deep reviews, max 3 proposals, evidence column |
| `SKILL.md` | Updated triggers: "skill botox audit", "skill botox mutate" |
| `evolution.md` | Remove weekly automation; link hook snippet |
| `metrics.md` | Dual headline metric definition |
| `README.md` | Honest v1 positioning |
| `docs/demo-audit.md` | Falsification test protocol (manual 10-skill eval) |
| `CHANGELOG.md` | v1.2.0 release notes |
| `.github/workflows/evals.yml` | Run semantic eval step |

---

### Task 1: Run artifact schema and init script

**Files:**
- Create: `references/runs/README.md`
- Create: `references/runs/.gitkeep`
- Create: `scripts/init-run.sh`
- Modify: `references/output-schemas.md`

- [ ] **Step 1: Create run directory placeholder**

Create `references/runs/.gitkeep` (empty file).

- [ ] **Step 2: Create run schema documentation**

Create `references/runs/README.md`:

```markdown
# Skill Botox Run Artifacts

Each orchestrator execution creates one file: `references/runs/<run-id>.md`.

## Run ID format

`YYYY-MM-DD-HHMM` (UTC or local — be consistent within a run)

## Resume protocol

If a run stops at the Decide checkpoint:
1. Read the existing run file
2. Continue from the step marked `status: pending`
3. Do not create a duplicate run ID

## Template sections (in order)

1. Run header (id, mode, scope, status)
2. Observation Report (or "skipped")
3. Analysis Report
4. Governor Verdicts (one per proposal)
5. Decision (user approval record)
6. Act log (files touched, or "none")
7. Lineage entries (or "none")

## Status values

`initialized` → `observed` → `analyzed` → `governed` → `decided` → `acted` → `closed`
```

- [ ] **Step 3: Add Run Artifact schema to output-schemas.md**

Append to `references/output-schemas.md`:

```markdown

## Run Artifact

Template (file: `references/runs/<run-id>.md`):

    # Skill Botox Run
    **Run ID:** YYYY-MM-DD-HHMM
    **Mode:** audit | mutate
    **Scope:** full | library | skill:<name>
    **Status:** initialized | observed | analyzed | governed | decided | acted | closed

    ## Observation Report
    (embedded or "skipped — library scope")

    ## Analysis Report
    (embedded)

    ## Governor Verdicts
    (one ## Governor Verdict block per proposal)

    ## Decision
    **User approval:** none | all | <list>
    **Approved proposals:** (numbered list or "none")

    ## Act Log
    | Action | Target | Result |
    |--------|--------|--------|

    ## Lineage
    (entries or "none")
```

Also update the Proposals table in Analysis Report section to add column:

```markdown
    | Action | Target | Rationale | Linked signals | Evidence |
    |--------|--------|-----------|----------------|----------|
    (create | evolve | prune | defer) — Evidence: signal | none | inferred
```

- [ ] **Step 4: Write init-run.sh**

Create `scripts/init-run.sh`:

```bash
#!/usr/bin/env bash
# Create a new Skill Botox run artifact.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNS="$ROOT/references/runs"
MODE="${1:-audit}"
SCOPE="${2:-full}"
RUN_ID="$(date +%Y-%m-%d-%H%M)"
OUT="$RUNS/$RUN_ID.md"

mkdir -p "$RUNS"

if [[ -f "$OUT" ]]; then
  echo "Run file already exists: $OUT" >&2
  exit 1
fi

cat > "$OUT" <<EOF
# Skill Botox Run
**Run ID:** $RUN_ID
**Mode:** $MODE
**Scope:** $SCOPE
**Status:** initialized

## Observation Report
(pending)

## Analysis Report
(pending)

## Governor Verdicts
(pending)

## Decision
**User approval:** pending
**Approved proposals:** pending

## Act Log
(pending)

## Lineage
(pending)
EOF

# Update last-run pointer
cat > "$ROOT/references/lineage/last-run.md" <<EOF
# Last Run

**Run ID:** $RUN_ID
**Mode:** $MODE
**Scope:** $SCOPE
**Artifact:** references/runs/$RUN_ID.md
**Started:** $(date -Iseconds)
EOF

echo "$OUT"
```

- [ ] **Step 5: Make executable and smoke test**

Run:

```bash
chmod +x scripts/init-run.sh
./scripts/init-run.sh audit library
```

Expected: prints path like `.../references/runs/2026-06-16-1430.md` and file exists with `**Status:** initialized`.

Run:

```bash
rm references/runs/2026-*.md 2>/dev/null || true
```

- [ ] **Step 6: Commit**

```bash
git add references/runs/ references/lineage/last-run.md references/output-schemas.md scripts/init-run.sh
git commit -m "feat: add run artifact schema and init-run script"
```

---

### Task 2: Semantic Governor heuristics (P-01, P-04, P-06)

**Files:**
- Create: `scripts/govern-semantic-check.sh`
- Test: manual via golden fixtures in Task 3

- [ ] **Step 1: Write govern-semantic-check.sh**

Create `scripts/govern-semantic-check.sh`:

```bash
#!/usr/bin/env bash
# Heuristic semantic checks mirroring Governor P-01, P-04, P-06.
# Agent Governor remains authoritative for edge cases; this catches regressions.
set -euo pipefail

TARGET="${1:?Usage: govern-semantic-check.sh <file.md> [--change-type create|modify|merge|prune]}"
CHANGE_TYPE="${2:-modify}"
[[ "$CHANGE_TYPE" == "--change-type" ]] && CHANGE_TYPE="${3:-modify}"

FAIL=0

pass() { echo "  PASS $1"; }
fail() { echo "  FAIL $1: $2"; FAIL=1; }
warn() { echo "  WARN $1: $2"; }

CONTENT="$(cat "$TARGET")"
BODY="$(awk 'BEGIN{p=0} /^---$/{c++; next} c>=2{p=1} p{print}' "$TARGET" 2>/dev/null || cat "$TARGET")"
DESC="$(awk '/^description:/ {
  sub(/^description:[[:space:]]*/, "");
  gsub(/^["'\''"]|["'\''"]$/, "");
  print; exit
}' "$TARGET")"

# P-01: Single responsibility — BLOCK if 3+ unrelated domain keywords without router pattern
DOMAIN_KEYWORDS='homelab|kubernetes|swiftui|postgres|figma|marketing|legal|fitness|finance|android|ios|react|python|rust|docker|terraform|aws|gcp|azure|video|audio|email|seo'
DOMAIN_HITS="$(echo "$DESC $BODY" | grep -oiE "$DOMAIN_KEYWORDS" | sort -u | wc -l | tr -d ' ')"
IS_ROUTER="$(echo "$DESC $BODY" | grep -qiE 'router|route to|delegates? to'; echo $?)"
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
```

- [ ] **Step 2: Make executable**

Run:

```bash
chmod +x scripts/govern-semantic-check.sh
```

- [ ] **Step 3: Commit**

```bash
git add scripts/govern-semantic-check.sh
git commit -m "feat: add semantic govern-check heuristics for P-01 P-04 P-06"
```

---

### Task 3: Semantic eval golden fixtures

**Files:**
- Create: `evals/golden-proposals/monolithic-homelab.md`
- Create: `evals/golden-proposals/duplicate-architect.md`
- Create: `evals/golden-proposals/clean-evolve.md`
- Create: `evals/golden-proposals/prune-no-lineage.md`
- Create: `evals/golden-proposals/router-ok.md`
- Create: `evals/expected-semantic-verdicts.json`
- Create: `evals/run-semantic-eval.sh`
- Modify: `evals/run-eval.sh`

- [ ] **Step 1: Create monolithic-homelab fixture (expect P-01 fail)**

Create `evals/golden-proposals/monolithic-homelab.md`:

```markdown
---
name: homelab-everything
description: Homelab kubernetes docker terraform aws networking storage backup skill. Use when managing homelab infrastructure.
version: 0.0.1
---

# Homelab Everything

One skill for kubernetes, docker, terraform, aws, postgres, and swiftui dashboards.
```

- [ ] **Step 2: Create duplicate-architect fixture (expect P-04 fail)**

Create `evals/golden-proposals/duplicate-architect.md`:

```markdown
---
name: my-skill-creator
description: Creates skills using Modular Skill Architect skill-creator 2.0 templates. Use when user asks to create a skill.
version: 0.0.1
---

# My Skill Creator

## Modular Skill Architect (skill-creator 2.0)

Routes requests to category-specific skill templates...
```

- [ ] **Step 3: Create clean-evolve fixture (expect all pass)**

Create `evals/golden-proposals/clean-evolve.md`:

```markdown
---
name: expo-observe-helper
description: Query EAS Observe metrics via eas CLI. Use when user asks about app launch times, TTR, or route metrics.
version: 1.0.0
---

# Expo Observe Helper

## Inputs

User question about app performance metrics.

## Outputs

Markdown summary of relevant Observe metrics.

## Procedure

1. Run `eas observe:metrics-summary`
2. Interpret results for the user's question
```

- [ ] **Step 4: Create prune-no-lineage fixture (expect P-06 fail)**

Create `evals/golden-proposals/prune-no-lineage.md`:

```markdown
---
name: obsolete-skill
description: Deprecated skill to remove. Use when testing prune without lineage.
version: 0.0.1
change-type: prune
---

# Obsolete Skill

Delete this skill immediately. No replacement.
```

- [ ] **Step 5: Create router-ok fixture (expect P-01 pass despite many domains)**

Create `evals/golden-proposals/router-ok.md`:

```markdown
---
name: homelab-router
description: Router skill that delegates homelab tasks to domain skills. Use when user asks about homelab kubernetes docker or terraform.
version: 0.0.1
---

# Homelab Router

Routes to kubernetes, docker, and terraform sub-skills. Does not implement them inline.
```

- [ ] **Step 6: Create expected-semantic-verdicts.json**

Create `evals/expected-semantic-verdicts.json`:

```json
{
  "fixtures": [
    {
      "path": "evals/golden-proposals/monolithic-homelab.md",
      "expect": { "P-01": "fail", "P-04": "pass", "P-06": "pass" }
    },
    {
      "path": "evals/golden-proposals/duplicate-architect.md",
      "expect": { "P-01": "pass", "P-04": "fail", "P-06": "pass" }
    },
    {
      "path": "evals/golden-proposals/clean-evolve.md",
      "expect": { "P-01": "pass", "P-04": "pass", "P-06": "pass" }
    },
    {
      "path": "evals/golden-proposals/prune-no-lineage.md",
      "expect": { "P-01": "pass", "P-04": "pass", "P-06": "fail" },
      "flags": ["--change-type", "prune"]
    },
    {
      "path": "evals/golden-proposals/router-ok.md",
      "expect": { "P-01": "pass", "P-04": "pass", "P-06": "pass" }
    }
  ]
}
```

- [ ] **Step 7: Write run-semantic-eval.sh**

Create `evals/run-semantic-eval.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SEMANTIC="$ROOT/scripts/govern-semantic-check.sh"
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
  local full="$ROOT/$path"

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
```

- [ ] **Step 8: Extend run-eval.sh to call semantic eval**

Replace `evals/run-eval.sh` tail (after structural checks, before final exit) with:

```bash
echo ""
echo "Running semantic eval harness..."
echo "------------------------------"
chmod +x "$ROOT/evals/run-semantic-eval.sh"
"$ROOT/evals/run-semantic-eval.sh"
SEMANTIC_EXIT=$?

echo ""
if [[ "$FAILURES" -eq 0 && "$SEMANTIC_EXIT" -eq 0 ]]; then
  echo "Eval harness: PASS (structural + semantic)"
  exit 0
else
  echo "Eval harness: FAIL"
  exit 1
fi
```

Remove the old standalone exit block at the bottom of `run-eval.sh`.

- [ ] **Step 9: Run full eval harness**

Run:

```bash
chmod +x evals/run-semantic-eval.sh
./evals/run-eval.sh
```

Expected: `Eval harness: PASS (structural + semantic)`

- [ ] **Step 10: Commit**

```bash
git add evals/golden-proposals/ evals/expected-semantic-verdicts.json evals/run-semantic-eval.sh evals/run-eval.sh
git commit -m "test: add semantic Governor golden fixtures and eval harness"
```

---

### Task 4: Dual headline stats

**Files:**
- Modify: `scripts/stats.sh`
- Modify: `metrics.md`

- [ ] **Step 1: Extend stats.sh with gap/BLOCK hints**

Replace the final echo block in `scripts/stats.sh` (from `echo ""` before Structural health) with:

```bash
# Count open gaps from last run artifact if present
GAPS=0
BLOCKS=0
LAST_RUN="$ROOT/references/lineage/last-run.md"
if [[ -f "$LAST_RUN" ]]; then
  RUN_FILE="$(awk '/^\*\*Artifact:\*\*/ {gsub(/^\*\*Artifact:\*\* /,""); print}' "$LAST_RUN" | head -1)"
  if [[ -n "$RUN_FILE" && -f "$ROOT/$RUN_FILE" ]]; then
    GAPS="$(grep -c '| gap |' "$ROOT/$RUN_FILE" 2>/dev/null || echo 0)"
    BLOCKS="$(grep -c '\*\*Result:\*\* BLOCK' "$ROOT/$RUN_FILE" 2>/dev/null || echo 0)"
  fi
fi

echo ""
echo "Structural health: ${HEALTH}% ($((CHECKED - VIOLATIONS))/$CHECKED pass govern-check)"
echo "Open gaps (last run): $GAPS"
echo "Unresolved BLOCKs (last run): $BLOCKS"
echo ""
echo "Headline: $TOTAL skills | ${HEALTH}% structural | $GAPS gaps | $BLOCKS BLOCKs"
echo ""
echo "Note: structural health measures format compliance, not skill usefulness."
echo "Run 'skill botox audit' for gap analysis."
```

- [ ] **Step 2: Update metrics.md Phase B headline**

Replace the `## Phase A Headline Metric` section in `metrics.md` with:

```markdown
## Headline Metrics (Phase B)

| Metric | Source | Healthy | Meaning |
|--------|--------|---------|---------|
| Structural health | `./scripts/stats.sh` | ≥90% | % skills passing P-02, P-03, P-05 govern-check |
| Open gaps | Last run artifact | 0 | Unfilled skill domains from Analyzer |
| Unresolved BLOCKs | Last run artifact | 0 | Governor BLOCK verdicts not yet addressed |

**Important:** Structural health alone does not prove skill usefulness. Pair with audit runs and friction evidence (F-xx signals).

Target for healthy library: **≥90% structural AND 0 unresolved BLOCKs**.
```

- [ ] **Step 3: Smoke test stats**

Run:

```bash
./scripts/stats.sh
```

Expected: new lines for gaps, BLOCKs, and the honesty note.

- [ ] **Step 4: Commit**

```bash
git add scripts/stats.sh metrics.md
git commit -m "feat: dual headline metrics with honest structural health caveat"
```

---

### Task 5: Orchestrator audit/mutate modes and run persistence

**Files:**
- Modify: `orchestrator/SKILL.md`
- Modify: `SKILL.md`
- Modify: `evolution.md`

- [ ] **Step 1: Rewrite orchestrator Step 0 and modes**

Replace `orchestrator/SKILL.md` Procedure section with:

```markdown
## Modes

| Mode | Trigger phrases | Writes |
|------|-----------------|--------|
| **audit** (default) | "run skill botox", "skill botox audit", "skill library health" | None — reports only |
| **mutate** | "skill botox mutate", "evolve skill X" (with approval) | One approved change max per run |

## Procedure

### Step 0 — Initialize

1. Infer mode: `mutate` if user says mutate/evolve AND intends a write; else `audit`
2. Infer scope from message (default: `full` for "run skill botox", `library` for "skill library health")
3. Run: `bash scripts/doctor.sh` — if FAIL, stop and report missing deps
4. Run: `bash scripts/init-run.sh <mode> <scope>` — capture run file path
5. If mode=mutate and skill-architect missing AND any create proposal likely: warn user, restrict to evolve-only

### Step 1 — Observe

Skip if scope=library OR user provided no session context.

**Required for full scope:** user must supply ≥1 friction bullet OR confirm "use session transcript only".

- Read and follow `observer/SKILL.md`
- Append Observation Report to run file; set status `observed`

### Step 2 — Analyze

- Read and follow `analyzer/SKILL.md` with scope
- **Cap: max 3 proposals per run**
- Append Analysis Report to run file; set status `analyzed`

### Step 3 — Govern

For each proposal (max 3):
- Read and follow `governor/SKILL.md`
- Run `bash scripts/govern-semantic-check.sh` on proposal text when available
- Append Governor Verdicts to run file; set status `governed`
- Drop BLOCK proposals unless user requests revision

### Step 4 — Decide (checkpoint)

Present summary table. Ask:

**audit mode:** "Defer all (default) or note follow-ups?"
**mutate mode:** "Approve ONE proposal? (number | none)"

Append Decision to run file; set status `decided`.

STOP if mutate mode and user approves none.

### Step 5 — Act (mutate mode only)

For the single approved proposal:
- **create | evolve** → read `evolver/SKILL.md`
- **prune** → user confirms delete; document in lineage only until delete approved
- Confirm before each filesystem write

Append Act Log; set status `acted`.

Skip entirely in audit mode.

### Step 6 — Record

If any action taken: read `lineage/SKILL.md` and append to run file + CHANGELOG.

Set status `closed`. Update `references/lineage/last-run.md` with completion timestamp.

### Step 7 — Close

Summarize: mode, run file path, signals addressed, verdicts, files touched, deferred items.

**Do not invoke experimenter in default loop.** Link `experimenter/SKILL.md` only if user explicitly requests A/B test.
```

- [ ] **Step 2: Update root SKILL.md activation**

Replace Activation section in `SKILL.md`:

```markdown
## Activation

| User says | Mode |
|-----------|------|
| "run skill botox", "skill botox audit" | audit |
| "skill botox mutate", "evolve skill X" | mutate |

1. Read `evolution.md` for trigger context
2. Read `orchestrator/SKILL.md` and execute from Step 0
3. Never skip Governor before any write
4. Persist all output to `references/runs/<run-id>.md`
```

- [ ] **Step 3: Update evolution.md triggers — remove weekly automation**

Replace Triggers table and add hook reference:

```markdown
## Triggers

| Trigger | Mode | Scope |
|---------|------|-------|
| User: "run skill botox" / "skill botox audit" | audit | Session + library |
| User: "skill library health" | audit | Library |
| User: "skill botox mutate" / "evolve skill X" | mutate | Single skill |
| Post-project debrief | audit | Session |

## Optional automation

See `references/hooks/post-session-reminder.md` for an AGENTS.md snippet or Cursor hook to remind you after large sessions. No built-in scheduler in v1.
```

Remove the "Weekly automation (optional)" row from the old table.

- [ ] **Step 4: Commit**

```bash
git add orchestrator/SKILL.md SKILL.md evolution.md
git commit -m "feat: audit/mutate modes with run persistence and scoped orchestrator"
```

---

### Task 6: Observer and Analyzer hardening

**Files:**
- Modify: `observer/SKILL.md`
- Modify: `analyzer/SKILL.md`

- [ ] **Step 1: Harden Observer — no invented signals**

Replace `observer/SKILL.md` Procedure with:

```markdown
## Procedure

1. **Check input source** (required):
   - User-provided friction bullets (preferred), OR
   - User confirms "analyze this session transcript only", OR
   - User points to prior session export path
   - If none: emit **"Insufficient observation input"** and stop — do not invent F-xx signals

2. Scan provided material for metrics signals F-01 through F-05 and S-01 through S-04 from `metrics.md`

3. Note skills mentioned, loaded, or should have loaded (from `<available_skills>` if visible)

4. **Do not invent signals** — cite verbatim user/agent quotes as evidence. If no quote supports a signal, omit it.

5. Severity: High (blocked task), Medium (workaround), Low (minor inefficiency)
```

- [ ] **Step 2: Harden Analyzer — caps and evidence**

Add after `### Inventory` in `analyzer/SKILL.md`:

```markdown
### Scope limits (v1)

| Scope | Deep review cap | Proposal cap |
|-------|-----------------|--------------|
| full/library | 5 skills (worst structural score + Observer-named skills first) | 3 |
| skill:X | 1 skill | 1 |

Structural pre-score: run `bash scripts/govern-check.sh` on each skill; prioritize failures.

### Evidence rule

Each proposal MUST include Evidence column:
- `signal` — linked F-xx or gap from Observer/Analysis with quote
- `inferred` — structural/rubric finding only (no session evidence)
- Proposals with `none` are BLOCKED unless user opts in with "allow evidence-free proposals"
```

- [ ] **Step 3: Commit**

```bash
git add observer/SKILL.md analyzer/SKILL.md
git commit -m "feat: require observation input and cap analyzer scope"
```

---

### Task 7: Post-session hook snippet and README honesty pass

**Files:**
- Create: `references/hooks/post-session-reminder.md`
- Modify: `README.md`
- Modify: `docs/demo-audit.md` (create)
- Modify: `CHANGELOG.md`
- Modify: `.github/workflows/evals.yml`

- [ ] **Step 1: Create hook snippet**

Create `references/hooks/post-session-reminder.md`:

```markdown
# Post-Session Skill Botox Reminder

Optional. Copy into project `AGENTS.md` or a Cursor user rule.

## Snippet

After completing a multi-step task (3+ tool calls or 1+ file writes), append to your mental checklist:

> If skill friction occurred (wrong skill loaded, repeated explanations, manual overrides), run **"skill botox audit"** and paste 1–3 friction bullets.

## Cursor Hook (future)

When Cursor session hooks support post-turn scripts, wire a reminder file write to `.cursor/skill-botox-reminder.md`. Not shipped in v1.
```

- [ ] **Step 2: Create falsification test protocol**

Create `docs/demo-audit.md`:

```markdown
# Skill Botox Audit — Falsification Test

Manual protocol to validate Analyzer proposal quality before trusting the loop.

## Setup (10 min)

1. Pick 10 installed skills (mix of good and suspect)
2. List 3 real friction events from recent work (bullets)
3. Run: `./scripts/stats.sh` — record structural %

## Execute (20 min)

1. New agent chat: "skill botox audit"
2. Paste your 3 friction bullets when Observer asks
3. Save run artifact from `references/runs/`

## Score (5 min)

For top 3 proposals, mark each:

| Score | Meaning |
|-------|---------|
| 2 | Would fix real friction you listed |
| 1 | Plausible but not tied to your friction |
| 0 | Wrong target or cosmetic |

**Pass threshold:** ≥4/6 total points (avg ≥1.3 per proposal)

**Fail action:** Revise Analyzer rubric or principles before marketing compounding improvement.
```

- [ ] **Step 3: Update README positioning**

Replace Vision section intro and Current Status in `README.md`:

```markdown
## Vision

Move from ad-hoc skill creation to a **governed audit and mutation workflow** that compounds improvement over time.

v1 delivers **audit + governed mutation**, not autonomous evolution. See [Framework Vision](docs/FRAMEWORK_VISION.md) for long-term goals.

## Current Status

**v1.2.0** — Phase B audit hardening: run persistence, dual metrics, semantic evals, audit/mutate modes.
```

Update headline metric line near top:

```markdown
**Headline metrics:** `./scripts/stats.sh` — structural health %, open gaps, unresolved BLOCKs (see [metrics.md](metrics.md)).
```

Add after Getting Started step 5:

```markdown
6. Validate with [falsification test](docs/demo-audit.md) before trusting proposals on your library
```

- [ ] **Step 4: Update CHANGELOG for v1.2.0**

Prepend to `CHANGELOG.md`:

```markdown
## [1.2.0] - 2026-06-16

### Added
- Run artifacts: `references/runs/`, `scripts/init-run.sh`
- Semantic Governor heuristics: `scripts/govern-semantic-check.sh`
- Semantic eval golden fixtures and `evals/run-semantic-eval.sh`
- Audit vs mutate orchestrator modes
- Post-session hook snippet: `references/hooks/post-session-reminder.md`
- Falsification test protocol: `docs/demo-audit.md`

### Changed
- Dual headline metrics in `stats.sh` and `metrics.md`
- Observer requires explicit friction input
- Analyzer capped at 5 deep reviews / 3 proposals
- README honest v1 positioning
- Removed weekly automation claim from `evolution.md`

```

- [ ] **Step 5: Update CI workflow**

Add after structural eval step in `.github/workflows/evals.yml`:

```yaml
      - name: Run semantic eval harness
        run: ./evals/run-semantic-eval.sh
```

(If `run-eval.sh` already invokes semantic eval, this step is redundant — prefer single `./evals/run-eval.sh` step only.)

- [ ] **Step 6: Bump plugin version**

In `.cursor-plugin/plugin.json`, set `"version": "1.2.0"`.

- [ ] **Step 7: Run full verification**

Run:

```bash
./scripts/doctor.sh
./evals/run-eval.sh
./scripts/stats.sh
./scripts/init-run.sh audit library && ls references/runs/
```

Expected: all pass, run file created.

- [ ] **Step 8: Commit**

```bash
git add references/hooks/ docs/demo-audit.md README.md CHANGELOG.md .cursor-plugin/plugin.json .github/workflows/evals.yml
git commit -m "docs: Phase B README honesty, falsification test, v1.2.0 release notes"
```

---

## Self-Review

### Spec coverage

| Devil's advocate recommendation | Task |
|----------------------------------|------|
| Run persistence (`references/runs/`) | Task 1, 5 |
| Dual headline metrics | Task 4 |
| Semantic Governor evals | Task 2, 3 |
| Audit vs mutate repositioning | Task 5 |
| Observer requires friction input | Task 6 |
| Analyzer scope caps | Task 6 |
| Kill weekly automation / optional hook | Task 5, 7 |
| Falsification test | Task 7 (`docs/demo-audit.md`) |
| README honesty | Task 7 |
| Experimenter deferred from default loop | Task 5 |

### Placeholder scan

No TBD/TODO/implement-later steps. All scripts include complete code.

### Type consistency

- Run ID format `YYYY-MM-DD-HHMM` consistent across init-run, orchestrator, output-schemas
- Mode values `audit | mutate` consistent across SKILL.md, orchestrator, evolution.md
- Evidence column values `signal | inferred | none` consistent across output-schemas and analyzer

### Out of scope (explicit YAGNI)

- Full LLM-based semantic Governor in CI (heuristics only; agent remains authoritative)
- Automatic weekly scheduler
- Staging directory writes (`skill-botox/staging/`) — defer to Phase C mutate hardening
- Outcome metric S-01 automation — requires platform hooks not available in v1

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-06-16-phase-b-audit-hardening.md`.

**Two execution options:**

1. **Subagent-Driven (recommended)** — dispatch a fresh subagent per task, review between tasks, fast iteration

2. **Inline Execution** — execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**
