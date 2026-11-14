# SkillSteroids Lineage Log

Append-only record of approved skill evolution actions.

---

## 2026-09-05 — in-plugin create/review (no off-repo skill deps)

- **Action:** evolve
- **Target:** plugin/skills/skill-steroids/ (principles, analyzer, evolver, governor, orchestrator, doctor, references)
- **Parent version:** principles 1.0.0 → **New version:** 1.1.0
- **Signals resolved:** gap (create/review required skills not shipped in this repo)
- **Lesson:** Product paths must resolve inside the pack. Create uses `templates/skill-template.md` + `references/skill-authoring.md`; review uses `references/skill-review-rubric.md`.

## 2026-09-05 — skill-experimenter 1.0.2 (apply-shape and wire-in)

- **Action:** evolve
- **Target:** plugin/skills/skill-steroids/experimenter/
- **Parent version:** 1.0.1 → **New version:** 1.0.2
- **Signals resolved:** gap (lazy add-file apply)
- **Lesson:** A sibling file that nothing routes to is not an apply; match winner grain, wire in, patch overlap, still graft the loser's unique criterion.
- **Skill-local log:** experimenter/CHANGELOG.md
- **Run:** `references/runs/2026-09-05-1345.md`

## 2026-09-05 — skill-experimenter 1.0.1 (apply without flatten)

- **Action:** evolve
- **Target:** plugin/skills/skill-steroids/experimenter/
- **Parent version:** 1.0.0 → **New version:** 1.0.1
- **Signals resolved:** gap (post-experiment apply)
- **Lesson:** Recommend-promote without apply rules caused models to flatten winner structure into a blended SKILL.md.
- **Skill-local log:** experimenter/CHANGELOG.md
- **Run:** `references/runs/2026-09-05-1341.md`

## 2026-09-04 — article-writer 3.1 (default Taylor voice)

- **Action:** evolve
- **Target:** ~/.agents/skills/article-writer/
- **Parent version:** 3.0 → **New version:** 3.1
- **Signals resolved:** F-02, F-03
- **Lesson:** Vendor the voice pack into the article skill; do not call a separate writing-voice skill at runtime.
- **Skill-local log:** ~/.agents/skills/article-writer/CHANGELOG.md


## 2026-07-14 — mission-control wire-in (Tess + Perry)

**Action:** create + evolve  
**Target:** `/Users/databased/Downloads/mission-control/references/pipeline-perry.md` (create); `/Users/databased/Downloads/mission-control/SKILL.md` (evolve)  
**Parent version:** career-autopilot pre-wire → **New version:** career-autopilot + Pipeline Perry + Tracker Tess routed  
**Signals resolved:** F-02, F-05, gap (orphaned ops specialists)  
**Lesson:** Ops specialists need router table + slash + topic routes + description triggers, or they stay dead weight even with complete reference files.  
**Run:** `references/runs/2026-07-14-1358.md`

---

## 2026-06-15 — framework bootstrap

**Action:** create  
**Target:** skill-steroids pack  
**Lesson:** Initial closed-loop scaffold implemented per implementation plan.

## 2026-07-19 — linear-operator 1.1.0

- **Action:** evolve
- **Target:** ~/.agents/skills/linear-operator/
- **Parent version:** 1.0.0 (unversioned) → **New version:** 1.1.0
- **Signals resolved:** F-03 (wrong MCP tool prefixes), underperform (inventory/verify drift)
- **Lesson:** Document bare Linear MCP tool names; host-specific prefixes break Cursor invocation.

## 2026-07-19 — linear-operator 1.2.0

- **Action:** evolve
- **Target:** ~/.agents/skills/linear-operator/
- **Parent version:** 1.1.0 → **New version:** 1.2.0
- **Signals resolved:** retroactive catch-up gap (close issues from untracked completed work)
- **Lesson:** Propose evidence→issue mapping table before any bulk close; keep procedure in progressive disclosure.

## 2026-07-19 — linear-operator 1.3.0

- **Action:** evolve
- **Target:** ~/.agents/skills/linear-operator/
- **Parent version:** 1.2.0 → **New version:** 1.3.0
- **Signals resolved:** end-of-session tracker sync (HTML update-tracker → Linear, project-agnostic)
- **Lesson:** Ritualize session sync with evidence checklist; keep Linear as tracker of record; resolve scope each run.

## 2026-07-21 — doctor.sh symlink + eval-runner gating fix

**Action:** evolve
**Target:** `scripts/doctor.sh`
**Parent version:** unversioned script → **New version:** unversioned script (behavior fix, no version field)
**Signals resolved:** inferred/structural — self-audit run `references/runs/2026-07-20-2035.md`
**Lesson:** `REPO_ROOT` must resolve the script's own directory with `cd -P` *before* walking `..` — plain `cd a/symlink/..` tracks the logical (lexical) path in bash, not the physical one, so it silently landed one level too shallow through the `~/.claude/skills/skill-steroids` → `packages/skill-pack` install symlink. Combined with marking the eval-runner check `required=1` (only Experimenter needs it, and Experimenter is explicitly excluded from the default loop), doctor FAILed on every real installed invocation, hard-blocking Step 0.3 for all mutate-mode runs outside this monorepo checkout. Demoted the check to optional, matching other optional doctor checks.

## 2026-07-24 — startup-design V1 infra-failure flow control

**Action:** evolve
**Target:** `startup-sage/plugins/startup-sage/skills/startup-sage/design/references/verification-agent.md`
**Parent version:** unversioned doc → **New version:** unversioned doc (Flow Control gains a third case)
**Signals resolved:** Gap (infra-failure handling), High severity — run `references/runs/2026-07-21-0941.md`
**Lesson:** Flow Control only covered "V1 produced a report" outcomes (Critical / Warnings-only). A V1 dispatch that fails outright (API/session error, no `verification-report.md`) had no documented path and stalled the session on an ad hoc AskUserQuestion. Added: retry once, then offer wait / manual-verification / proceed-with-caveat. Deviation note: proposal named only "verification-agent.md" — applied directly, no placement ambiguity.

## 2026-07-24 — startup-design durable output-path guidance

**Action:** evolve
**Target:** `startup-sage/plugins/startup-sage/skills/startup-sage/design/references/output-guidelines.md`
**Parent version:** unversioned doc → **New version:** unversioned doc (new "Output Path Resolution" section)
**Signals resolved:** Gap (durable-output-path guidance), High severity — run `references/runs/2026-07-21-0941.md`
**Lesson:** `{project-name}` was used as a path prefix throughout `design.md` and wave references with no guidance on resolving it to a durable location; a session-scoped scratchpad write silently lost 11 raw + 5 synthesis files (~2h of agent research) before verification ran. Deviation note: proposal offered a choice of `SKILL.md` or `output-guidelines.md` — this skill's actual entry file is `design.md` (repo has no `SKILL.md`), and output-guidelines.md already owns file-output conventions, so the addition landed there rather than duplicating into the orchestrator file.

## 2026-07-24 — startup-design access-blocked vs. no-data-found research failures

**Action:** evolve
**Target:** `startup-sage/plugins/startup-sage/skills/startup-sage/design/references/research-principles.md`
**Parent version:** unversioned doc → **New version:** unversioned doc (Handling Research Failures gains step 6)
**Signals resolved:** F-03 (workaround path, recurring), Medium severity — run `references/runs/2026-07-21-0941.md`
**Lesson:** "Handling Research Failures" only covered no-data-found; two independent Wave 3 agents across two full session runs hit identical Reddit site-search-empty / WebFetch-refused / G2 403 patterns and improvised the same workaround twice with no documented protocol. Added a distinct access-blocked sub-case: ≥2 alternate strategies, then declare the block explicitly with tool-level error text preserved, rather than folding it into a generic DATA GAP.

## 2026-08-01 — code-explainer 1.1.0 dual-view HTML

**Action:** evolve
**Target:** `~/.agents/skills/code-explainer/`
**Parent version:** unversioned → **New version:** 1.1.0
**Signals resolved:** F-03 (markdown report not in shareable HTML)
**Lesson:** Codemap-first HTML needs a Report view with the same narrative as the `.md` twin so one self-contained file carries map + write-up for teammates.
**Run:** `references/runs/2026-08-01-1518.md`

## 2026-08-01 — code-explainer 1.2.0 themeable exploration

**Action:** evolve
**Target:** `~/.agents/skills/code-explainer/`
**Parent version:** 1.1.0 → **New version:** 1.2.0
**Signals resolved:** F-03 (single hard-coded dark appearance)
**Lesson:** Standalone shareable HTML needs native semantic CSS tokens and a fault-tolerant local theme preference, rather than build-time Tailwind directives.
**Run:** `references/runs/2026-08-01-1526.md`

## 2026-08-04 — chrome-browser-extension-builder 2.1.0

**Action:** create
**Target:** `~/.agents/skills/chrome-browser-extension-builder/` (+ Cursor symlink; pack symlink under `browser-extension-skills/skills/`)
**Parent version:** n/a (draft-only run 2026-08-04-1050) → **New version:** 2.1.0
**Signals resolved:** F-03 (6-field cap, empty Notion select, popup UI), F-05 (builder name miss), draft-never-installed
**Lesson:** Install PRD-driven builder on disk with Noted self-checks (all writable mappings, omit empty selects, popup density, schema sync) or product code regresses.
**Skill-local log:** `~/.agents/skills/chrome-browser-extension-builder/CHANGELOG.md`
**Run:** `references/runs/2026-08-04-1213.md`
