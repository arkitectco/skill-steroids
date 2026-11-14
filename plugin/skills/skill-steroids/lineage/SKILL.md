---
name: skill-lineage
description: Records approved skill mutations, versions, and lessons for SkillSteroids. Appends to references/lineage/CHANGELOG.md. Use after orchestrator Act step or when user says "record skill lineage".
disable-model-invocation: true
version: 1.0.0
---

# Skill Lineage

Preserves institutional knowledge without bloating active skills.

History lives with the skill it's about, not just with this tool. `references/lineage/CHANGELOG.md`
is an index — one line per entry, pointing back to the skill's own log. The skill's own
`CHANGELOG.md` is the source of truth; it travels if the skill dir is copied or shared elsewhere,
the central index does not.

## Procedure

1. For each approved change, emit Lineage Entry per `references/output-schemas.md`
2. Resolve target-skill-dir: `bash scripts/skill-inventory.sh` and grep for the target skill name.
   If unresolved (skill dir not found under any known root), mark entry "index-only" and skip step 3.
3. Append the same entry to `<target-skill-dir>/CHANGELOG.md` (create with a one-line header if
   missing) — this is the skill's full record
4. Append a condensed line to `references/lineage/CHANGELOG.md` under a new dated heading: date,
   action, target, version bump, and relative path to the skill-local `CHANGELOG.md`
5. For prunes: record final lesson learned and redirect triggers to replacement skill if any

## Prune policy

Never delete changelog entries, in either location. Pruned skills get a final "archived" entry
with reason, written to the skill-local log if still resolvable, always to the central index.

## Output

Confirm both appends with file paths and entry summary. If skill-local write was skipped
(unresolved dir), say so explicitly — don't silently fall back to index-only.
