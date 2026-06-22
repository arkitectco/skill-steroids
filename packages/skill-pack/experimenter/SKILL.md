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
