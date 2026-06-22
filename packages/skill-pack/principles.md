# SkillSteroids Principles (Living Constitution)

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
