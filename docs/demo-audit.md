# SkillSteroids Audit — Falsification Test

Manual protocol to validate Analyzer proposal quality before trusting the loop.

## Setup (10 min)

1. Pick 10 installed skills (mix of good and suspect)
2. List 3 real friction events from recent work (bullets)
3. Run: `./scripts/stats.sh` — record structural %

## Execute (20 min)

1. New agent chat: "skill steroids audit"
2. Paste your 3 friction bullets when Observer asks
3. Save run artifact from `references/runs/`

## Score (5 min)

For top 3 proposals, mark each:

| Score | Meaning |
|-------|---------|
| 2 | Would fix real friction you listed |
| 1 | Plausible but not tied to your friction |
| 0 | Wrong target or cosmetic |

**Pass threshold:** ≥4/6 total points (avg ≥1.3 per proposal)

**Fail action:** Revise Analyzer rubric or principles before marketing compounding improvement.
