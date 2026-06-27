---
name: using-skill-steroids
description: Establishes when and how to invoke SkillSteroids for skill library audit or mutation. Injected at session start via plugin hook — not for manual file reads.
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute an unrelated task, skip this skill.
</SUBAGENT-STOP>

# Using SkillSteroids

Session orientation only. This is **not** the full audit/mutate framework.

## Purpose

SkillSteroids governs evolution of your AI agent skill library. Load the full `skill-steroids` skill only when the user asks for library audit or mutation — never for normal coding tasks.

## When to invoke `skill-steroids`

| User intent | Example phrases | Mode |
|-------------|-------------------|------|
| Health report | "run skill steroids", "skill steroids audit", "skill library health" | audit |
| Governed change | "skill steroids mutate", "evolve skill X" | mutate |

## When NOT to invoke

Normal feature work, bug fixes, refactors, and general coding are **not** skill library evolution. Do not load `skill-steroids` unless the user clearly wants skill-library audit or mutation.

## How to invoke

Use your platform's skill-loading mechanism to load **`skill-steroids`**. Do not manually read orchestrator, governor, or evolver files with file tools.

## Post-session friction nudge

After completing a multi-step task (3+ tool calls or 1+ file writes), if skill friction occurred — wrong skill loaded, repeated explanations, manual overrides — **suggest** (do not auto-run):

> Run **"skill steroids audit"** and share 1–3 friction bullets.

This is a gentle reminder only. Never start the audit loop without an explicit user request.
