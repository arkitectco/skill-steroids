---
name: skill-botox-orchestrator
description: Coordinates the Skill Botox loop Observe → Analyze → Govern → Decide → Act → Record. Loaded by root skill-botox entry. Use only via orchestrator step or explicit "run skill botox orchestrator".
disable-model-invocation: true
version: 1.0.0
---

# Skill Botox Orchestrator

## Inputs

| Input | Source |
|-------|--------|
| User intent | Current message |
| Session context | Conversation history |
| Scope | full | library | skill:<name> (infer from message) |

## Outputs

Combined markdown report with sections from `references/output-schemas.md` in order:
Observation (if run) → Analysis → Governor verdicts → Decision summary → Lineage (if acted)

## Procedure

### Step 0 — Initialize

- Generate Run ID: `YYYY-MM-DD-HHMM`
- State scope from user message (default: `full` when "run skill botox")

### Step 1 — Observe (skip if scope=library only)

- Read and follow `observer/SKILL.md`
- Collect Observation Report

### Step 2 — Analyze

- Read and follow `analyzer/SKILL.md` with scope
- Collect Analysis Report with Proposals table

### Step 3 — Govern

For **each** proposal row:
- Read and follow `governor/SKILL.md`
- Attach Governor Verdict
- Drop BLOCK proposals unless user requests revision

### Step 4 — Decide (checkpoint)

Present summary table:

| Proposal | Governor | Recommended action |
|----------|----------|-------------------|

Ask: **"Approve which proposals? (none | all | list numbers)"**

STOP if user approves none.

### Step 5 — Act

For each approved proposal:
- **create | evolve** → read `evolver/SKILL.md`
- **experiment** → read `experimenter/SKILL.md` (if implemented)
- **prune** → user confirms delete; document in lineage only until delete approved

Again: confirm before each filesystem write.

### Step 6 — Record

- Read and follow `lineage/SKILL.md` for each applied change
- Append to `references/lineage/CHANGELOG.md`

### Step 7 — Close

Summarize: signals addressed, verdicts, files touched, follow-ups deferred.

## Error handling

- Missing external skill-architect: stop Evolver; tell user to install at `~/.agents/skills/skill-architect/`
- Zero proposals: report healthy library or insufficient data; suggest manual Observer notes
