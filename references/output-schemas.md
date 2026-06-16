# Skill Botox Output Schemas

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
    | Action | Target | Rationale | Linked signals |
    |--------|--------|-----------|----------------|
    (create | evolve | prune | experiment | defer)

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
