---
name: skill-experimenter
description: Defines safe A/B tests between skill variants with explicit success criteria from metrics.md. Does not auto-promote winners. Use when Analyzer proposal action is experiment or user asks to A/B test a skill change.
disable-model-invocation: true
version: 1.0.2
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

6. Recommend B as apply-base only if B wins majority AND Governor PASS on B. "Promote" means step 7 (winner structure + loser's leftover), not B unchanged.
7. Graft onto the winner's existing architecture — never flatten or blend into a new SKILL.md
   - **Shape:** if the winner already splits into referenced files, put the loser's unique strength in a sibling file of the same kind. Edit SKILL.md only to route, trigger, and link. Do not paste that content into SKILL.md.
   - **Wire-in (required):** a new file is invalid until description triggers, the winner's router/table, and one inbound cross-ref all point at it.
   - **Overlap:** if the winner already has that concern, patch the existing file; do not add a parallel file.
   - **Majority win still grafts** the loser's unique criterion.
   - **Keep both** if triggers are disjoint or neither has a unique graftable strength — do not merge.
   - **Reject apply** if any referenced file disappeared or a mode/reference was reduced to bullets in SKILL.md.
   - Present the apply plan; write only after user approval. Then follow evolver (lineage action: evolve). Experiment result stays lineage action: experiment

## Constraints

- Variants live in user-approved temp paths or branches — never overwrite production skill without approval
- Experiments append to lineage with action: experiment
- When applying, never inline content the winner already keeps in referenced files
- A sibling file with no route, description trigger, or inbound link does not count as applied
