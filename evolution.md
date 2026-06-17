# SkillSteroids Process

## Loop

1. **Observe** — Capture session friction and usage signals (`observer/SKILL.md`)
2. **Analyze** — Library-wide gaps, overlap, drift (`analyzer/SKILL.md`)
3. **Govern** — Validate proposals against `principles.md` (`governor/SKILL.md`)
4. **Decide** — Orchestrator picks: Create | Evolve | Prune | Defer
5. **Act** — Evolver / user-approved edits (mutate mode only)
6. **Record** — Lineage + metrics update (`lineage/SKILL.md`)

## Triggers

| Trigger | Mode | Scope |
|---------|------|-------|
| User: "run skill steroids" / "skill steroids audit" | audit | Session + library |
| User: "skill library health" | audit | Library |
| User: "skill steroids mutate" / "evolve skill X" | mutate | Single skill |
| Post-project debrief | audit | Session |

## Optional automation

See `references/hooks/post-session-reminder.md` for an AGENTS.md snippet or Cursor hook to remind you after large sessions. No built-in scheduler in v1.

## Decision Tree (Orchestrator)

```
IF friction signals >= 2 OR user requested full loop:
  RUN observer → analyzer
ELSE IF user named specific skill:
  RUN analyzer (scoped) → governor on proposals
ELSE:
  RUN analyzer (quick inventory) only

FOR each proposal (max 3):
  RUN governor
  IF BLOCK → drop or revise (max 1 revise attempt)
  IF WARN → surface to user with mitigations
  IF PASS → queue for user approval

IF mutate mode AND user approves ONE proposal:
  RUN evolver
  RUN lineage record
ELSE:
  STOP with summary (audit mode: no writes)
```

Human checkpoint required before any filesystem write.
