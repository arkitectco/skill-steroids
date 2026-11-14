---
name: skill-steroids
description: Meta-framework for deliberate evolution of an AI agent skill library. Orchestrates observation, analysis, governance, and governed mutation. Use when the user says "run skill steroids", "skill steroids audit", "skill steroids mutate", "evolve my skills", "skill library health", "skill debt", "review my skills", or asks to improve their skill collection systematically.
disable-model-invocation: true
user-invocable: true
argument-hint: "[audit|mutate] [scope]"
version: 2.3.1
---

# SkillSteroids Framework

Entry point for the skill library evolution loop.

## Activation

Natural-language phrases work on every host. Claude/Grok slash-command shims live in the plugin `commands/` directory (`audit`, `mutate`) — do not copy those host prefixes into this file.

| User says | Mode |
|-----------|------|
| "run skill steroids", "skill steroids audit", "skill library health" | audit |
| "skill steroids mutate", "evolve skill X" | mutate |

`$ARGUMENTS` is `audit` or `mutate` plus optional scope. Empty arguments → audit.

1. Read `evolution.md` for trigger context
2. Read `orchestrator/SKILL.md` and execute from Step 0
3. Never skip Governor before any write
4. Persist all output to `.skill-steroids/runs/<run-id>.md` (project-local, not pack source)

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

## Monorepo note

When cloned from GitHub, skill content lives at `plugin/skills/skill-steroids/`. Eval fixtures and the web app live at repo root (`evals/`, `apps/web/`). Users install the `./plugin` marketplace package — not a separate skill-pack symlink.

## Human-in-the-loop

v1 produces reports and proposals only. Ask explicit approval before creating, editing, or deleting any skill file.
