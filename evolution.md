# Skill Botox Process

## Loop

1. **Observe** — Capture session friction and usage signals (`observer/SKILL.md`)
2. **Analyze** — Library-wide gaps, overlap, drift (`analyzer/SKILL.md`)
3. **Govern** — Validate proposals against `principles.md` (`governor/SKILL.md`)
4. **Decide** — Orchestrator picks: Create | Evolve | Experiment | Prune | Defer
5. **Act** — Evolver / Experimenter / user-approved edits
6. **Record** — Lineage + metrics update (`lineage/SKILL.md`)

## Triggers

| Trigger | Mode | Scope |
|---------|------|-------|
| User: "run skill botox" | Full loop | Session + library |
| User: "skill library health" | Analyze + Govern | Library |
| User: "evolve skill X" | Evolve path | Single skill |
| Weekly automation (optional) | Analyze only | Library |
| Post-project debrief | Observe + Analyze | Session |

## Decision Tree (Orchestrator)

```
IF friction signals >= 2 OR user requested full loop:
  RUN observer → analyzer
ELSE IF user named specific skill:
  RUN analyzer (scoped) → governor on proposals
ELSE:
  RUN analyzer (quick inventory) only

FOR each proposal:
  RUN governor
  IF BLOCK → drop or revise (max 1 revise attempt)
  IF WARN → surface to user with mitigations
  IF PASS → queue for user approval

IF user approves:
  RUN evolver (or experimenter if A/B)
  RUN lineage record
ELSE:
  STOP with summary
```

Human checkpoint required before any filesystem write.
