---
name: skill-steroids
description: Meta-framework for deliberate evolution of an AI agent skill library. Orchestrates observation, analysis, governance, and governed mutation. Use when the user says "run skill steroids", "skill steroids audit", "skill steroids mutate", "evolve my skills", "skill library health", "skill debt", "review my skills", or asks to improve their skill collection systematically.
disable-model-invocation: true
version: 2.0.0
---

# SkillSteroids Framework

Entry point for the skill library evolution loop.

## Activation

| User says | Mode |
|-----------|------|
| "run skill steroids", "skill steroids audit" | audit |
| "skill steroids mutate", "evolve skill X" | mutate |

1. Read `evolution.md` for trigger context
2. Read `orchestrator/SKILL.md` and execute from Step 0
3. Never skip Governor before any write
4. Persist all output to `references/runs/<run-id>.md`

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
