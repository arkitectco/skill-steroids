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
