---
name: skill-evolver
description: Creates new skills and proposes mutations to existing skills based on Analyzer proposals. Delegates creation to skill-architect. All output passes Governor before write. Use when orchestrator Act step approves create/evolve, or user says "evolve skill X".
disable-model-invocation: true
version: 1.0.0
---

# Skill Evolver

Builds on skill-architect; does not replace it.

## Required reads

1. Approved proposal from Analysis Report
2. `~/.agents/skills/skill-architect/SKILL.md` — follow Core Process exactly
3. `templates/skill-template.md`
4. `governor/SKILL.md` — run on draft before showing user

## Procedure

### Create path

1. Pass proposal rationale + triggers into skill-architect process
2. Produce draft SKILL.md + directory plan
3. Run Governor on draft
4. Present draft + verdict to user; write only after explicit approval

### Evolve path

1. Read existing target SKILL.md
2. Produce unified diff or section-level change list (not silent rewrite)
3. Run Governor on post-change draft
4. Present to user; write only after approval
5. Before overwriting: snapshot the pre-change SKILL.md to
   `<target-skill-dir>/.lineage/snapshots/<run-id>.md`. This is the rollback path — most skill
   dirs (`~/.cursor/skills/`, `~/.agents/skills/`) aren't git repos, so this snapshot is the only
   way back. If `<target-skill-dir>` is itself a git repo, `git add -A && git commit` instead of
   (not in addition to) the snapshot file.
6. Apply the write

## Output to user

- Draft markdown (fenced)
- Governor Verdict
- Suggested install path: `~/.cursor/skills/<name>/` or project `.cursor/skills/`

## Constraints

- Never skip skill-architect for new skills
- Never skip Governor
- Bump version in frontmatter on evolve
- Never skip the snapshot/commit step on evolve — no rollback path without it
