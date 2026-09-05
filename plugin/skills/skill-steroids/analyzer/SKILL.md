---
name: skill-analyzer
description: Performs systemic analysis across the user's skill library for gaps, overlap, principle drift, and underperformance. Use in SkillSteroids Analyze step or when user asks "skill library health", "find skill gaps", "skill redundancy".
disable-model-invocation: true
version: 1.0.0
---

# Skill Analyzer

Library-wide intelligence on top of the in-pack per-skill review rubric.

## Required reads

1. `principles.md`, `metrics.md`
2. `references/skill-review-rubric.md`
3. `references/output-schemas.md`

## Procedure

### Inventory

Run: `bash scripts/skill-inventory.sh --library`  
Dedupes the same skill copied into `~/.cursor/skills`, `~/.agents/skills`, and `~/.claude/skills`. Use `--pack` for this plugin only.  
If script unavailable, manually scan those user skill dirs (once, not three times).

### Scope limits (v1)

| Scope | Deep review cap | Proposal cap |
|-------|-----------------|--------------|
| full/library | 5 skills (worst structural score + Observer-named skills first) | 3 |
| skill:X | 1 skill | 1 |

Structural pre-score: run `bash scripts/govern-check.sh` on each skill; prioritize failures.

### Per-skill review (sample or full based on scope)

- **full/library**: deep review up to cap (see above)
- **skill:X**: review named skill only
- Apply `references/skill-review-rubric.md`; record OK/WARN/FAIL

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

### Evidence rule

Each proposal MUST include Evidence column:
- `signal` — linked F-xx or gap from Observer/Analysis with quote
- `inferred` — structural/rubric finding only (no session evidence)
- Proposals with `none` are BLOCKED unless user opts in with "allow evidence-free proposals"

Do not edit files. Proposals only.
