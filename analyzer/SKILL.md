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
