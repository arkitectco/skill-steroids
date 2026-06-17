# Skill Botox Framework Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the Skill Botox scaffold into a production-ready, installable personal skill pack that runs a closed-loop Observe → Analyze → Govern → Decide → Act → Record workflow with human-in-the-loop checkpoints.

**Architecture:** Multi-skill pack installed at `~/.cursor/skills/skill-botox/` (symlinked from this repo). Root `SKILL.md` is a thin router with explicit triggers. Shared constitution lives in top-level `principles.md`, `metrics.md`, and `evolution.md`. Sub-skills (`governor/`, `orchestrator/`, etc.) are invoked by the orchestrator via `Read`, not auto-discovered. External meta-skills are delegated to, not duplicated: `~/.agents/skills/skill-architect/SKILL.md` for creation, and skill-destroyer review patterns for analysis (install separately or vendor later).

**Tech Stack:** Markdown skills (Cursor Agent Skills format), optional minimal shell for inventory scan in `scripts/`, git for lineage commits.

---

## File Map (locked before tasks)

| Path | Responsibility |
|------|----------------|
| `SKILL.md` | Entry router; trigger phrases; loads orchestrator |
| `principles.md` | Living constitution; Governor enforces this |
| `metrics.md` | Objective friction/success/health signals |
| `evolution.md` | Loop definition, triggers, decision tree |
| `governor/SKILL.md` | PASS/WARN/BLOCK gate on all proposals |
| `orchestrator/SKILL.md` | State machine coordinating sub-skills |
| `observer/SKILL.md` | Session/conversation friction capture |
| `analyzer/SKILL.md` | Library-wide systemic review |
| `evolver/SKILL.md` | Create/mutate skills via skill-architect |
| `experimenter/SKILL.md` | Safe A/B variant testing (phase 2) |
| `lineage/SKILL.md` | Append-only mutation log |
| `references/integration-external-skills.md` | Paths and delegation rules |
| `references/output-schemas.md` | Shared JSON-ish markdown output formats |
| `references/lineage/CHANGELOG.md` | Append-only evolution history |
| `templates/skill-template.md` | Starter for new skills from Evolver |
| `scripts/skill-inventory.sh` | Optional: list skill dirs for Analyzer |
| `README.md` | Install symlink instructions |
| `.cursor-plugin/plugin.json` | Phase 2 plugin wrapper (optional) |

**Out of scope v1:** Autonomous file writes without user approval, real-time telemetry, marketplace publish.

---

## Verification Approach (skill-pack TDD)

This project has no pytest suite. Each task ends with a **verification scenario**: a prompt + expected output structure. Treat failing scenarios like failing tests — fix before moving on.

Verification log file (create in Task 1):

- `docs/superpowers/plans/verification-log.md`

---

### Task 1: Foundation docs and verification harness

**Files:**
- Modify: `principles.md`
- Modify: `metrics.md`
- Modify: `evolution.md`
- Create: `references/output-schemas.md`
- Create: `docs/superpowers/plans/verification-log.md`

- [ ] **Step 1: Expand `principles.md` with enforceable rules**

Replace entire file with:

```markdown
# Skill Botox Principles (Living Constitution)

Version: 1.0.0  
Last updated: 2026-06-15

The Governor enforces these rules on every proposed skill create, modify, merge, or prune.

## Core Values

1. **Modularity** — One skill, one primary job. Split when a SKILL.md exceeds ~450 lines or covers unrelated triggers.
2. **Composability** — Skills delegate to other skills; never duplicate skill-architect or skill-destroyer workflows inline.
3. **Clarity** — Imperative instructions, explicit inputs/outputs, named trigger phrases in descriptions.
4. **Low cognitive load** — No teaching the model what it already knows; no filler prose.
5. **Principle-driven** — Every skill aligns with this file; cite principle ID on violations.
6. **Human-in-the-loop** — v1: proposals only; user approves each write/delete.
7. **Measurable improvement** — Every change links to a friction or gap signal from Observer/Analyzer.

## Enforceable Rules (Governor checklist)

| ID | Rule | BLOCK if |
|----|------|----------|
| P-01 | Single responsibility | Skill handles 2+ unrelated domains without router pattern |
| P-02 | Trigger-rich description | Description missing WHEN triggers or under 20 chars |
| P-03 | No bloat | SKILL.md body > 500 lines without references/ split |
| P-04 | No duplication | Re-implements skill-architect templates or destroyer rubric |
| P-05 | Explicit I/O | Missing Input/Output section for orchestrator skills |
| P-06 | Safe evolution | Proposes delete/replace without lineage entry plan |
| P-07 | Compatible stacks | Conflicts with Superpowers process skills without override note |
| P-08 | Markdown-first | Adds script when markdown suffices (see PRD scripts policy) |

## Anti-Patterns

- Vibe-based instructions ("be smart", "use best judgment" without criteria)
- Monolithic meta-skills that embed the full evolution loop
- Auto-invocation (`disable-model-invocation` omitted) on meta/framework skills
- Orphan skills with no trigger phrases and no orchestrator reference

## Amendment Process

1. Propose diff to this file via Evolver + Governor review.
2. Bump version and `Last updated` date.
3. Append entry to `references/lineage/CHANGELOG.md`.
```

- [ ] **Step 2: Expand `metrics.md` with scoring rubric**

Replace entire file with:

```markdown
# Skill Botox Metrics & Signals

Use these labels in Observer and Analyzer outputs. Numeric scores are optional in v1; qualitative High/Medium/Low is sufficient.

## Friction Signals (Observer)

| Signal ID | Description | Typical evidence |
|-----------|-------------|------------------|
| F-01 | Context re-explanation | User repeats same constraints 2+ times in session |
| F-02 | Skill ignored | Relevant skill exists but agent did not load it |
| F-03 | Workaround path | User manually overrides agent approach repeatedly |
| F-04 | Token waste | Long skill loaded for trivial task |
| F-05 | Trigger miss | User says trigger phrase; wrong skill or none loads |

## Success Signals

| Signal ID | Description |
|-----------|-------------|
| S-01 | Skill invoked on first relevant turn |
| S-02 | Task completed without principle violations |
| S-03 | User accepts proposal without major edits |
| S-04 | Reduced steps vs prior similar session |

## Library Health (Analyzer)

| Metric | Healthy | Watch | Unhealthy |
|--------|---------|-------|-----------|
| Review coverage | >50% skills reviewed in 30d | 25–50% | <25% |
| Redundancy | No overlapping triggers | 1–2 overlaps | 3+ overlaps same domain |
| Gap coverage | Domain has skill | Partial | Repeated manual work, no skill |
| Principle violations | 0 BLOCK in last run | WARN only | Any unresolved BLOCK |

## Improvement Definition

A change is an improvement only if it resolves ≥1 friction/gap signal AND passes Governor with PASS or WARN (not BLOCK).
```

- [ ] **Step 3: Expand `evolution.md` with decision tree**

Replace entire file with:

```markdown
# Skill Botox Process

## Loop

1. **Observe** — Capture session friction and usage signals (`observer/SKILL.md`)
2. **Analyze** — Library-wide gaps, overlap, drift (`analyzer/SKILL.md`)
3. **Govern** — Validate proposals against `principles.md` (`governor/SKILL.md`)
4. **Decide** — Orchestrator picks: Create | Evolve | Experiment | Prune | Defer
5. **Act** — Evolver / Experimenter / user-approved edits
6. **Record** — Lineage + metrics update (`lineage/SKILL.md`)

## Triggers

| Trigger | Mode | Scope |
|---------|------|-------|
| User: "run skill botox" | Full loop | Session + library |
| User: "skill library health" | Analyze + Govern | Library |
| User: "evolve skill X" | Evolve path | Single skill |
| Weekly automation (optional) | Analyze only | Library |
| Post-project debrief | Observe + Analyze | Session |

## Decision Tree (Orchestrator)

```
IF friction signals >= 2 OR user requested full loop:
  RUN observer → analyzer
ELSE IF user named specific skill:
  RUN analyzer (scoped) → governor on proposals
ELSE:
  RUN analyzer (quick inventory) only

FOR each proposal:
  RUN governor
  IF BLOCK → drop or revise (max 1 revise attempt)
  IF WARN → surface to user with mitigations
  IF PASS → queue for user approval

IF user approves:
  RUN evolver (or experimenter if A/B)
  RUN lineage record
ELSE:
  STOP with summary
```

Human checkpoint required before any filesystem write.
```

- [ ] **Step 4: Create `references/output-schemas.md`**

Create file:

```markdown
# Skill Botox Output Schemas

All sub-skills MUST emit these sections so Orchestrator can compose results.

## Observation Report

```markdown
## Observation Report
**Run ID:** YYYY-MM-DD-HHMM
**Scope:** session | library | skill:<name>

### Friction Signals
| ID | Severity | Evidence |
|----|----------|----------|

### Success Signals
| ID | Evidence |
|----|----------|

### Raw Notes
(bullets)
```

## Analysis Report

```markdown
## Analysis Report
**Run ID:** YYYY-MM-DD-HHMM
**Skills scanned:** N

### Findings
| Type | Skill | Detail | Priority |
|------|-------|--------|----------|
(gap | overlap | drift | underperform)

### Proposals
| Action | Target | Rationale | Linked signals |
|--------|--------|-----------|----------------|
(create | evolve | prune | experiment | defer)
```

## Governor Verdict

```markdown
## Governor Verdict
**Target:** <skill or proposal id>
**Result:** PASS | WARN | BLOCK

### Violations
| Principle | Severity | Fix |
|-----------|----------|-----|

### Required changes before approval
(numbered list or "none")
```

## Lineage Entry

```markdown
## Lineage Entry
**Date:** YYYY-MM-DD
**Action:** create | evolve | prune | experiment
**Target:** path
**Parent version:** x.y.z → **New version:** x.y.z
**Signals resolved:** F-xx, gap-y
**Lesson:** one sentence
```
```

- [ ] **Step 5: Create verification log**

Create `docs/superpowers/plans/verification-log.md`:

```markdown
# Skill Botox Verification Log

| Task | Scenario | Date | Result | Notes |
|------|----------|------|--------|-------|
```

- [ ] **Step 6: Commit**

```bash
git add principles.md metrics.md evolution.md references/output-schemas.md docs/superpowers/plans/
git commit -m "docs: flesh out skill botox constitution, metrics, and output schemas"
```

---

### Task 2: Governor (quality gate)

**Files:**
- Modify: `governor/SKILL.md`
- Create: `references/integration-external-skills.md` (partial — Governor section)

- [ ] **Step 1: Write Governor skill**

Replace `governor/SKILL.md` entirely:

```markdown
---
name: skill-governor
description: Enforces Skill Botox principles.md on proposed skill creates, modifications, merges, and prunes. Returns PASS, WARN, or BLOCK with cited violations. Use when reviewing any skill change, before applying Evolver output, or when the orchestrator reaches the Govern step.
disable-model-invocation: true
version: 1.0.0
---

# Skill Governor

Quality gate for the Skill Botox framework. **No proposed change proceeds without a Governor verdict.**

## When invoked

- Orchestrator Govern step
- User: "govern this skill change", "check against principles"
- Before writing any skill file from Evolver

## Required reads (in order)

1. `principles.md` (repo root of skill-botox pack)
2. Target SKILL.md or proposal text
3. `references/output-schemas.md` → Governor Verdict section
4. If reviewing structure/quality depth: `~/.agents/skills/skill-architect/SKILL.md` anti-bloat sections only

## Procedure

1. Identify change type: **create | modify | merge | prune**
2. Run checklist P-01 through P-08 from `principles.md`
3. For modify/prune: verify lineage plan exists (P-06)
4. Assign **PASS**, **WARN**, or **BLOCK**:
   - **BLOCK** — any P-xx BLOCK condition met; do not apply change
   - **WARN** — minor issues; user may approve with noted mitigations
   - **PASS** — no violations
5. Emit Governor Verdict schema exactly

## Severity rules

- Missing triggers, bloat, duplication → BLOCK
- Borderline length (450–500 lines) → WARN with split recommendation
- Compatibility note missing for Superpowers overlap → WARN

## Output

Emit only the Governor Verdict markdown block. Do not rewrite the skill unless user asks.

## Example BLOCK

```markdown
## Governor Verdict
**Target:** proposal:create homelab-everything
**Result:** BLOCK

### Violations
| Principle | Severity | Fix |
|-----------|----------|-----|
| P-01 | BLOCK | Split into router + 3 domain skills |
| P-02 | BLOCK | Add trigger phrases to description |

### Required changes before approval
1. Narrow scope to one homelab subdomain
2. Rewrite description with WHEN triggers
```
```

- [ ] **Step 2: Start integration reference (Governor section)**

Create `references/integration-external-skills.md`:

```markdown
# External Skill Integration

Do not duplicate these skills. Read and delegate.

| Skill | Path | Used by |
|-------|------|---------|
| skill-architect | `~/.agents/skills/skill-architect/SKILL.md` | Evolver (create/refactor) |
| skill-destroyer | Install separately; apply review rubric | Analyzer (per-skill review) |

If skill-destroyer is unavailable, use `references/skill-destroyer-rubric.md` (copy from destroyer when installed).

## Delegation rule

Sub-skills say **what** to delegate. They do not embed architect/destroyer bodies.
```

- [ ] **Step 3: Verification scenario — Governor BLOCK**

Prompt (in fresh agent chat with skill pack installed):

> Read governor/SKILL.md and govern this proposal: a new skill `mega-helper` with description "Helps with stuff" and 600 lines covering git, docker, and resume writing.

Expected: Governor Verdict with **Result: BLOCK**, citations P-01, P-02, P-03.

- [ ] **Step 4: Log result in verification-log.md**

- [ ] **Step 5: Commit**

```bash
git add governor/SKILL.md references/integration-external-skills.md docs/superpowers/plans/verification-log.md
git commit -m "feat: implement skill governor quality gate"
```

---

### Task 3: Root router + Orchestrator

**Files:**
- Modify: `SKILL.md`
- Modify: `orchestrator/SKILL.md`

- [ ] **Step 1: Rewrite root `SKILL.md` as router**

Replace entire file:

```markdown
---
name: skill-botox
description: Meta-framework for deliberate closed-loop evolution of an AI agent skill library. Orchestrates observation, analysis, governance, experimentation, and improvement. Use when the user says "run skill botox", "evolve my skills", "skill library health", "skill debt", "review my skills", or asks to improve their skill collection systematically.
disable-model-invocation: true
version: 1.0.0
---

# Skill Botox Framework

Entry point for the skill library evolution loop.

## Activation

1. Read `evolution.md` for trigger context
2. Read `orchestrator/SKILL.md` and execute from step 1
3. Never skip Governor before any write

## Pack layout

| Component | Path |
|-----------|------|
| Orchestrator | `orchestrator/SKILL.md` |
| Governor | `governor/SKILL.md` |
| Observer | `observer/SKILL.md` |
| Analyzer | `analyzer/SKILL.md` |
| Evolver | `evolver/SKILL.md` |
| Experimenter | `experimenter/SKILL.md` |
| Lineage | `lineage/SKILL.md` |
| Constitution | `principles.md` |
| Metrics | `metrics.md` |

## Human-in-the-loop

v1 produces reports and proposals only. Ask explicit approval before creating, editing, or deleting any skill file.
```

- [ ] **Step 2: Implement Orchestrator state machine**

Replace `orchestrator/SKILL.md` entirely:

```markdown
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
```

- [ ] **Step 3: Verification scenario — orchestrator dry run**

Prompt:

> run skill botox (analysis only — do not write files)

Expected: Agent loads root → orchestrator → analyzer stub or partial; **no file writes**; asks for approval before act step.

- [ ] **Step 4: Commit**

```bash
git add SKILL.md orchestrator/SKILL.md docs/superpowers/plans/verification-log.md
git commit -m "feat: add skill-botox router and orchestrator state machine"
```

---

### Task 4: Observer

**Files:**
- Modify: `observer/SKILL.md`

- [ ] **Step 1: Implement Observer**

Replace `observer/SKILL.md`:

```markdown
---
name: skill-observer
description: Captures friction and success signals from the current agent session or user-provided notes for Skill Botox. Use during orchestrator Observe step or when user says "observe skill friction", "what skill problems happened this session".
disable-model-invocation: true
version: 1.0.0
---

# Skill Observer

## Inputs

- Current conversation transcript (required)
- Optional: user pointer to prior session export
- Optional: manual bullets user provides inline

## Procedure

1. Scan conversation for metrics signals F-01 through F-05 and S-01 through S-04 from `metrics.md`
2. Note skills mentioned, loaded, or should have loaded (from `<available_skills>` if visible)
3. Do not invent signals — cite verbatim user/agent quotes as evidence
4. Severity: High (blocked task), Medium (workaround), Low (minor inefficiency)

## Output

Emit Observation Report per `references/output-schemas.md`.

If no evidence for any signal, state: **"No friction signals detected in scope."** and list skills that worked well.

## Limits (v1)

- No background telemetry
- No filesystem log unless user asks to append to `references/lineage/observations.md`
```

- [ ] **Step 2: Verification scenario**

Use a mock transcript in prompt:

> Observer: In this session the user asked for PDF help three times and restated "use my team template" twice. Agent never loaded any PDF skill.

Expected: F-01 High, F-02 Medium with quoted evidence.

- [ ] **Step 3: Commit**

```bash
git add observer/SKILL.md
git commit -m "feat: implement session-based skill observer"
```

---

### Task 5: Analyzer

**Files:**
- Modify: `analyzer/SKILL.md`
- Create: `scripts/skill-inventory.sh`
- Create: `references/skill-destroyer-rubric.md` (minimal fallback)

- [ ] **Step 1: Create skill inventory script**

Create `scripts/skill-inventory.sh`:

```bash
#!/usr/bin/env bash
# Lists SKILL.md files under common skill roots. Read-only.
set -euo pipefail

roots=(
  "$HOME/.cursor/skills"
  "$HOME/.agents/skills"
  "$HOME/.claude/skills"
)

for root in "${roots[@]}"; do
  if [[ -d "$root" ]]; then
    echo "=== $root ==="
    find "$root" -name 'SKILL.md' -not -path '*/.*' 2>/dev/null | sort
  fi
done
```

```bash
chmod +x scripts/skill-inventory.sh
```

- [ ] **Step 2: Create destroyer rubric fallback**

Create `references/skill-destroyer-rubric.md`:

```markdown
# Skill Review Rubric (fallback)

Use when skill-destroyer skill is not installed. Per skill:

1. **Trigger accuracy** — Description matches real user phrases?
2. **Bloat** — Teaches obvious model knowledge?
3. **Structure** — Frontmatter valid; progressive disclosure?
4. **Overlap** — Duplicate of another installed skill?
5. **Drift** — Body contradicts `principles.md`?

Score each: OK | WARN | FAIL. FAIL → proposal to evolve or prune.
```

- [ ] **Step 3: Implement Analyzer**

Replace `analyzer/SKILL.md`:

```markdown
---
name: skill-analyzer
description: Performs systemic analysis across the user's skill library for gaps, overlap, principle drift, and underperformance. Complements skill-destroyer with library-wide view. Use in Skill Botox Analyze step or when user asks "skill library health", "find skill gaps", "skill redundancy".
disable-model-invocation: true
version: 1.0.0
---

# Skill Analyzer

Evolves skill-destroyer's per-skill review into library-wide intelligence.

## Required reads

1. `principles.md`, `metrics.md`
2. `references/skill-destroyer-rubric.md` OR `skill-destroyer` skill if installed
3. `references/output-schemas.md`

## Procedure

### Inventory

Run: `bash scripts/skill-inventory.sh`  
If script unavailable, manually scan `~/.cursor/skills` and `~/.agents/skills`.

### Per-skill review (sample or full based on scope)

- **full/library**: review all skills (batch by directory)
- **skill:X**: review named skill only
- Apply destroyer rubric; record OK/WARN/FAIL

### Systemic passes

| Pass | Detect |
|------|--------|
| Gap | User domains from Observer with no matching skill |
| Overlap | Same trigger phrases across 2+ skills |
| Drift | Violates P-01–P-08 |
| Underperform | FAIL rubric or F-02 from Observer |

### Proposals

Emit Analysis Report with prioritized proposals:
- Priority 1: BLOCK-level drift, critical gaps
- Priority 2: overlap, WARN-level issues
- Priority 3: optimizations

Link each proposal to signal IDs.

Do not edit files. Proposals only.
```

- [ ] **Step 4: Verification scenario**

Run:

```bash
bash scripts/skill-inventory.sh | head -20
```

Expected: lists paths under at least one root.

Prompt:

> Analyze skill library health (read-only). Use analyzer skill.

Expected: Analysis Report table with ≥1 finding or explicit "no issues" with scanned count.

- [ ] **Step 5: Commit**

```bash
git add analyzer/SKILL.md scripts/skill-inventory.sh references/skill-destroyer-rubric.md
git commit -m "feat: implement library analyzer with inventory script"
```

---

### Task 6: Evolver

**Files:**
- Modify: `evolver/SKILL.md`
- Modify: `templates/skill-template.md`

- [ ] **Step 1: Update skill template**

Replace `templates/skill-template.md`:

```markdown
---
name: your-skill-name
description: Third-person WHAT + WHEN triggers. Use when user mentions ...
disable-model-invocation: true
version: 0.1.0
---

# Skill Name

## Core Responsibilities

(one primary job)

## Inputs

## Outputs

## Procedure

(numbered steps)

## Integration

(skills this delegates to)

## Anti-Patterns

(from principles.md relevant IDs)
```

- [ ] **Step 2: Implement Evolver**

Replace `evolver/SKILL.md`:

```markdown
---
name: skill-evolver
description: Creates new skills and proposes mutations to existing skills based on Analyzer proposals. Delegates creation to skill-architect. All output passes Governor before write. Use when orchestrator Act step approves create/evolve, or user says "evolve skill X".
disable-model-invocation: true
version: 1.0.0
---

# Skill Evolver

Builds on skill-architect; does not replace it.

## Required reads

1. Approved proposal from Analysis Report
2. `~/.agents/skills/skill-architect/SKILL.md` — follow Core Process exactly
3. `templates/skill-template.md`
4. `governor/SKILL.md` — run on draft before showing user

## Procedure

### Create path

1. Pass proposal rationale + triggers into skill-architect process
2. Produce draft SKILL.md + directory plan
3. Run Governor on draft
4. Present draft + verdict to user; write only after explicit approval

### Evolve path

1. Read existing target SKILL.md
2. Produce unified diff or section-level change list (not silent rewrite)
3. Run Governor on post-change draft
4. Present to user; write only after approval

## Output to user

- Draft markdown (fenced)
- Governor Verdict
- Suggested install path: `~/.cursor/skills/<name>/` or project `.cursor/skills/`

## Constraints

- Never skip skill-architect for new skills
- Never skip Governor
- Bump version in frontmatter on evolve
```

- [ ] **Step 3: Verification scenario**

Prompt:

> Evolver: propose a new skill `pdf-form-filler` for PDF form tasks (do not write files). User triggers: "fill this PDF form", "PDF forms".

Expected: draft SKILL.md + Governor Verdict PASS or WARN (not BLOCK).

- [ ] **Step 4: Commit**

```bash
git add evolver/SKILL.md templates/skill-template.md
git commit -m "feat: implement evolver with skill-architect delegation"
```

---

### Task 7: Lineage

**Files:**
- Modify: `lineage/SKILL.md`
- Create: `references/lineage/CHANGELOG.md`

- [ ] **Step 1: Create changelog seed**

Create `references/lineage/CHANGELOG.md`:

```markdown
# Skill Botox Lineage Log

Append-only record of approved skill evolution actions.

---

## 2026-06-15 — framework bootstrap

**Action:** create  
**Target:** skill-botox pack  
**Lesson:** Initial closed-loop scaffold implemented per implementation plan.
```

- [ ] **Step 2: Implement Lineage skill**

Replace `lineage/SKILL.md`:

```markdown
---
name: skill-lineage
description: Records approved skill mutations, versions, and lessons for Skill Botox. Appends to references/lineage/CHANGELOG.md. Use after orchestrator Act step or when user says "record skill lineage".
disable-model-invocation: true
version: 1.0.0
---

# Skill Lineage

Preserves institutional knowledge without bloating active skills.

## Procedure

1. For each approved change, emit Lineage Entry per `references/output-schemas.md`
2. Append entry to `references/lineage/CHANGELOG.md` under new dated heading
3. For prunes: record final lesson learned and redirect triggers to replacement skill if any

## Prune policy

Never delete changelog entries. Pruned skills get a final "archived" entry with reason.

## Output

Confirm append with file path and entry summary.
```

- [ ] **Step 3: Verification scenario**

Prompt:

> Record lineage for a hypothetical evolve of skill-botox orchestrator 1.0.0 → 1.0.1 fixing typo (dry run — show entry only).

Expected: valid Lineage Entry markdown block.

- [ ] **Step 4: Commit**

```bash
git add lineage/SKILL.md references/lineage/CHANGELOG.md
git commit -m "feat: implement lineage tracking and changelog"
```

---

### Task 8: Experimenter (minimal v1)

**Files:**
- Modify: `experimenter/SKILL.md`

- [ ] **Step 1: Implement minimal Experimenter**

Replace `experimenter/SKILL.md`:

```markdown
---
name: skill-experimenter
description: Defines safe A/B tests between skill variants with explicit success criteria from metrics.md. Does not auto-promote winners. Use when Analyzer proposal action is experiment or user asks to A/B test a skill change.
disable-model-invocation: true
version: 1.0.0
---

# Skill Experimenter

## Procedure

1. Name control (A) and variant (B) — usually current SKILL.md vs proposed draft
2. Define 2–3 task prompts that represent real triggers
3. Define success criteria from S-01–S-04 and F-01–F-05
4. Run mentally or with user executing two sessions — do not auto-run hidden tests
5. Record result table:

| Criterion | A | B | Winner |
|-----------|---|---|--------|

6. Recommend promote B only if B wins majority AND Governor PASS on B

## Constraints

- Variants live in user-approved temp paths or branches — never overwrite production skill without approval
- Experiments append to lineage with action: experiment
```

- [ ] **Step 2: Commit**

```bash
git add experimenter/SKILL.md
git commit -m "feat: add minimal skill experimenter for A/B proposals"
```

---

### Task 9: Install, README, end-to-end verification

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add install section to README**

Append after Getting Started:

```markdown
## Install (personal skill pack)

```bash
ln -sf "$(pwd)" ~/.cursor/skills/skill-botox
```

Verify: start a new agent chat and ask **"run skill botox"**. Agent should load root SKILL.md and orchestrator without writing files until you approve.

## Uninstall

```bash
rm ~/.cursor/skills/skill-botox
```
```

- [ ] **Step 2: Create symlink**

```bash
ln -sf /Users/databased/Developer/03-Agentic/Skills/SkillBotox ~/.cursor/skills/skill-botox
ls -la ~/.cursor/skills/skill-botox
```

Expected: symlink pointing to repo.

- [ ] **Step 3: End-to-end verification scenario**

New agent chat prompt:

> run skill botox on this project — read only, no writes

Expected sequence:
1. Loads skill-botox root + orchestrator
2. Observer report (may be minimal)
3. Analyzer runs inventory script
4. Governor verdicts on any proposals
5. Stops at approval checkpoint

- [ ] **Step 4: Record PASS in verification-log.md**

- [ ] **Step 5: Commit**

```bash
git add README.md docs/superpowers/plans/verification-log.md
git commit -m "docs: add install instructions and complete v1 verification"
```

---

### Task 10: Plugin wrapper (optional phase 2)

**Files:**
- Create: `.cursor-plugin/plugin.json`

- [ ] **Step 1: Create plugin manifest**

```json
{
  "name": "skill-botox",
  "version": "1.0.0",
  "description": "Meta-framework for deliberate evolution of your AI agent skill library.",
  "author": {
    "name": "arkitectco"
  },
  "keywords": ["skills", "meta", "evolution", "governance"]
}
```

- [ ] **Step 2: Document in README** — add "Plugin packaging" note pointing to `.cursor-plugin/`

- [ ] **Step 3: Commit**

```bash
git add .cursor-plugin/plugin.json README.md
git commit -m "chore: add cursor plugin manifest for skill-botox"
```

---

## Self-Review

### Spec coverage

| PRD requirement | Task |
|-----------------|------|
| Orchestrator | Task 3 |
| Governor | Task 2 |
| Observer | Task 4 |
| Analyzer (+ destroyer complement) | Task 5 |
| Evolver (+ skill-architect) | Task 6 |
| Experimenter | Task 8 |
| Lineage | Task 7 |
| principles.md constitution | Task 1 |
| metrics.md | Task 1 |
| evolution.md | Task 1 |
| Human-in-the-loop | Tasks 3, 6 |
| Markdown-first, optional scripts | Task 5 script only |
| No autonomous writes v1 | Tasks 3, 6 |
| Installable skill pack | Task 9 |

### Placeholder scan

No TBD/TODO steps. Each task includes full file content or exact commands.

### Gaps noted

- **skill-destroyer** not on disk in repo — Task 5 uses fallback rubric; install destroyer separately when available.
- **skill-architect** path assumes `~/.agents/skills/skill-architect/` — verify exists before Evolver E2E test.

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-06-15-skill-botox-framework.md`.

**Two execution options:**

1. **Subagent-Driven (recommended)** — dispatch a fresh subagent per task, review between tasks, fast iteration

2. **Inline Execution** — execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**
