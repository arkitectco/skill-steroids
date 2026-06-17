---
name: skill-steroids-orchestrator
description: Coordinates the SkillSteroids loop Observe → Analyze → Govern → Decide → Act → Record. Loaded by root skill-steroids entry. Use only via orchestrator step or explicit "run skill steroids orchestrator".
disable-model-invocation: true
version: 1.2.0
---

# SkillSteroids Orchestrator

## Inputs

| Input | Source |
|-------|--------|
| User intent | Current message |
| Session context | Conversation history |
| Scope | full | library | skill:<name> (infer from message) |
| Mode | audit (default) | mutate |

## Outputs

Combined markdown report with sections from `references/output-schemas.md` in order:
Observation (if run) → Analysis → Governor verdicts → Decision summary → Lineage (if acted)

Persist all sections to `references/runs/<run-id>.md`.

## Modes

| Mode | Trigger phrases | Writes |
|------|-----------------|--------|
| **audit** (default) | "run skill steroids", "skill steroids audit", "skill library health" | None — reports only |
| **mutate** | "skill steroids mutate", "evolve skill X" (with approval) | One approved change max per run |

## Procedure

### Step 0 — Initialize

1. Infer mode: `mutate` if user says mutate/evolve AND intends a write; else `audit`
2. Infer scope from message (default: `full` for "run skill steroids", `library` for "skill library health")
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

Present summary table:

| Proposal | Governor | Recommended action |
|----------|----------|-------------------|

Ask:

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

## Error handling

- Missing external skill-architect: stop Evolver; tell user to install at `~/.agents/skills/skill-architect/`
- Zero proposals: report healthy library or insufficient data; suggest manual Observer notes
