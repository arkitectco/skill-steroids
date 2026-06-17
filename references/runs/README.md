# SkillSteroids Run Artifacts

Each orchestrator execution creates one file: `references/runs/<run-id>.md`.

## Run ID format

`YYYY-MM-DD-HHMM` (UTC or local — be consistent within a run)

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
