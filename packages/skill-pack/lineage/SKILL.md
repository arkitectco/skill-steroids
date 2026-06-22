---
name: skill-lineage
description: Records approved skill mutations, versions, and lessons for SkillSteroids. Appends to references/lineage/CHANGELOG.md. Use after orchestrator Act step or when user says "record skill lineage".
disable-model-invocation: true
version: 1.0.0
---

# Skill Lineage

Preserves institutional knowledge without bloating active skills.

## Procedure

1. For each approved change, emit Lineage Entry per `references/output-schemas.md`
2. Append entry to `references/lineage/CHANGELOG.md` under new dated heading
3. For prunes: record final lesson learned and redirect triggers to replacement skill if any

## Prune policy

Never delete changelog entries. Pruned skills get a final "archived" entry with reason.

## Output

Confirm append with file path and entry summary.
