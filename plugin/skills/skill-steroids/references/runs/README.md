# SkillSteroids Run Artifacts

> **Since v2.4:** Run artifacts persist in the **invoking project**, not in the pack source tree.
> New runs land at `<project-root>/.skill-steroids/runs/<run-id>.md`.
> This directory contains only legacy runs from before that change.

## Run ID format

`YYYY-MM-DD-HHMM` (UTC or local — be consistent within a run)

## Where runs go

`init-run.sh` resolves the project root in order:
1. `$SKILL_STEROIDS_PROJECT_ROOT` (explicit override)
2. `git rev-parse --show-toplevel` (git repo root)
3. `$PWD` (fallback)

The run file and `last-run.md` pointer both land under `<project-root>/.skill-steroids/`.

## Resume protocol

If a run stops at the Decide checkpoint:
1. Read the existing run file
2. Continue from the step marked `status: pending`
3. Do not create a duplicate run ID

## Template sections (in order)

1. Run header (id, mode, scope, status)
2. Observation Report (or "skipped")
3. Analysis Report
4. Governor Verdicts (one per proposal)
5. Decision (user approval record)
6. Act log (files touched, or "none")
7. Lineage entries (or "none")

## Status values

`initialized` → `observed` → `analyzed` → `governed` → `decided` → `acted` → `closed`
