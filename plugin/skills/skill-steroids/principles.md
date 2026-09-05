# SkillSteroids Principles (Living Constitution)

Version: 1.1.0  
Last updated: 2026-09-05

The Governor enforces these rules on every proposed skill create, modify, merge, or prune.

## Core Values

1. **Modularity** — One skill, one primary job. Split when a SKILL.md exceeds ~450 lines or covers unrelated triggers.
2. **Composability** — Skills delegate to other installed skills; never paste another skill's body, templates, or rubric inline.
3. **Clarity** — Imperative instructions, explicit inputs/outputs, named trigger phrases in descriptions.
4. **Low cognitive load** — No teaching the model what it already knows; no filler prose.
5. **Principle-driven** — Every skill aligns with this file; cite principle ID on violations.
6. **Human-in-the-loop** — v1: proposals only; user approves each write/delete.
7. **Measurable improvement** — Every change links to a friction or gap signal from Observer/Analyzer.

## Enforceable Rules (Governor checklist)

| ID | Rule | BLOCK if |
|----|------|----------|
| P-01 | Single responsibility | Skill handles 2+ unrelated domains without router pattern |
| P-02 | Trigger-rich description | Description has no situation cue, under 20 chars, or over 500 chars |
| P-03 | No bloat | SKILL.md body > 500 lines without references/ split |
| P-04 | No duplication | Pastes another skill's body, templates, or the pack review rubric into a different skill |
| P-05 | Explicit I/O | Missing Input/Output section for orchestrator skills |
| P-06 | Safe evolution | Proposes delete/replace without lineage entry plan |
| P-07 | Compatible stacks | Conflicts with other installed process skills without an override note |
| P-08 | Markdown-first | Adds script when markdown suffices (see PRD scripts policy) |

## Anti-Patterns

- Vibe-based instructions ("be smart", "use best judgment" without criteria)
- Monolithic meta-skills that embed the full evolution loop
- Auto-invocation (`disable-model-invocation` omitted) on meta/framework skills
- Orphan skills with no trigger phrases and no orchestrator reference
- Description bloat: every skill's `description` is loaded into context on every session,
  regardless of whether it fires. Length there is pure recurring tax, unlike SKILL.md body
  (loaded once, on trigger). One dense sentence beats three loose ones.
  - Target: ≤150 chars WHAT + WHEN in one sentence. WARN at 300, BLOCK at 500 (P-02).
  - Redundant trigger phrases are the usual bloat source — "review, audit, check, or inspect"
    collapses to "review"; list only phrases that are NOT synonyms of each other.
  - A long description is not more trigger-rich, it's more expensive. Cut, don't append.

## Amendment Process

1. Propose diff to this file via Evolver + Governor review.
2. Bump version and `Last updated` date.
3. Append entry to `references/lineage/CHANGELOG.md`.
