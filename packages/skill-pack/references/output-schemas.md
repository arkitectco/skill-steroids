# SkillSteroids Output Schemas

All sub-skills MUST emit these sections so Orchestrator can compose results.

## Observation Report

Template:

    ## Observation Report
    **Run ID:** YYYY-MM-DD-HHMM
    **Scope:** session | library | skill:<name>

    ### Friction Signals
    | ID | Severity | Evidence |
    |----|----------|----------|

    ### Success Signals
    | ID | Evidence |
    |----|----------|

    ### Raw Notes
    (bullets)

## Analysis Report

Template:

    ## Analysis Report
    **Run ID:** YYYY-MM-DD-HHMM
    **Skills scanned:** N

    ### Findings
    | Type | Skill | Detail | Priority |
    |------|-------|--------|----------|
    (gap | overlap | drift | underperform)

    ### Proposals
    | Action | Target | Rationale | Linked signals | Evidence |
    |--------|--------|-----------|----------------|----------|
    (create | evolve | prune | defer) — Evidence: signal | none | inferred

## Governor Verdict

Template:

    ## Governor Verdict
    **Target:** <skill or proposal id>
    **Result:** PASS | WARN | BLOCK

    ### Violations
    | Principle | Severity | Fix |
    |-----------|----------|-----|

    ### Required changes before approval
    (numbered list or "none")

## Lineage Entry

Template:

    ## Lineage Entry
    **Date:** YYYY-MM-DD
    **Action:** create | evolve | prune | experiment
    **Target:** path
    **Parent version:** x.y.z → **New version:** x.y.z
    **Signals resolved:** F-xx, gap-y
    **Lesson:** one sentence

## Run Artifact

Template (file: `references/runs/<run-id>.md`):

    # SkillSteroids Run
    **Run ID:** YYYY-MM-DD-HHMM
    **Mode:** audit | mutate
    **Scope:** full | library | skill:<name>
    **Status:** initialized | observed | analyzed | governed | decided | acted | closed

    ## Observation Report
    (embedded or "skipped — library scope")

    ## Analysis Report
    (embedded)

    ## Governor Verdicts
    (one ## Governor Verdict block per proposal)

    ## Decision
    **User approval:** none | all | <list>
    **Approved proposals:** (numbered list or "none")

    ## Act Log
    | Action | Target | Result |
    |--------|--------|--------|

    ## Lineage
    (entries or "none")
