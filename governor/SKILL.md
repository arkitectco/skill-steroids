---
name: skill-governor
description: Enforces Skill Botox principles.md on proposed skill creates, modifications, merges, and prunes. Returns PASS, WARN, or BLOCK with cited violations. Use when reviewing any skill change, before applying Evolver output, or when the orchestrator reaches the Govern step.
disable-model-invocation: true
version: 1.0.0
---

# Skill Governor

Quality gate for the Skill Botox framework. **No proposed change proceeds without a Governor verdict.**

## When invoked

- Orchestrator Govern step
- User: "govern this skill change", "check against principles"
- Before writing any skill file from Evolver

## Required reads (in order)

1. `principles.md` (repo root of skill-botox pack)
2. Target SKILL.md or proposal text
3. `references/output-schemas.md` → Governor Verdict section
4. If reviewing structure/quality depth: `~/.agents/skills/skill-architect/SKILL.md` anti-bloat sections only

## Procedure

1. Identify change type: **create | modify | merge | prune**
2. Run checklist P-01 through P-08 from `principles.md`
3. For modify/prune: verify lineage plan exists (P-06)
4. Assign **PASS**, **WARN**, or **BLOCK**:
   - **BLOCK** — any P-xx BLOCK condition met; do not apply change
   - **WARN** — minor issues; user may approve with noted mitigations
   - **PASS** — no violations
5. Emit Governor Verdict schema exactly

## Severity rules

- Missing triggers, bloat, duplication → BLOCK
- Borderline length (450–500 lines) → WARN with split recommendation
- Compatibility note missing for Superpowers overlap → WARN

## Output

Emit only the Governor Verdict markdown block. Do not rewrite the skill unless user asks.

## Example BLOCK

```markdown
## Governor Verdict
**Target:** proposal:create homelab-everything
**Result:** BLOCK

### Violations
| Principle | Severity | Fix |
|-----------|----------|-----|
| P-01 | BLOCK | Split into router + 3 domain skills |
| P-02 | BLOCK | Add trigger phrases to description |

### Required changes before approval
1. Narrow scope to one homelab subdomain
2. Rewrite description with WHEN triggers
```
