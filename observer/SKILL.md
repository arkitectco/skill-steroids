---
name: skill-observer
description: Captures friction and success signals from the current agent session or user-provided notes for Skill Botox. Use during orchestrator Observe step or when user says "observe skill friction", "what skill problems happened this session".
disable-model-invocation: true
version: 1.0.0
---

# Skill Observer

## Inputs

- Current conversation transcript (required)
- Optional: user pointer to prior session export
- Optional: manual bullets user provides inline

## Procedure

1. Scan conversation for metrics signals F-01 through F-05 and S-01 through S-04 from `metrics.md`
2. Note skills mentioned, loaded, or should have loaded (from `<available_skills>` if visible)
3. Do not invent signals — cite verbatim user/agent quotes as evidence
4. Severity: High (blocked task), Medium (workaround), Low (minor inefficiency)

## Output

Emit Observation Report per `references/output-schemas.md`.

If no evidence for any signal, state: **"No friction signals detected in scope."** and list skills that worked well.

## Limits (v1)

- No background telemetry
- No filesystem log unless user asks to append to `references/lineage/observations.md`
