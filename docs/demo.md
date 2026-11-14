# 60-Second SkillSteroids Demo

Record with [asciinema](https://asciinema.org/) or terminal cast:

```bash
# 1. Plugin is installed (marketplace or Open Local Plugin → plugin/)

# 2. Doctor
./plugin/skills/skill-steroids/scripts/doctor.sh

# 3. Eval proof
./evals/run-eval.sh

# 4. Library scan (unique user skills). --pack = this plugin only
./plugin/skills/skill-steroids/scripts/stats.sh

# 5. Single skill check
./plugin/skills/skill-steroids/scripts/govern-check.sh evals/golden-violations/short-desc/SKILL.md
```

**Narration beats:**

1. "Install the plugin — not a separate skill pack"
2. "Doctor verifies the plugin pack"
3. "Eval harness — 100% on golden fixtures"
4. "Stats gives structural health score"
5. "Govern-check catches bad skills before they ship"

Upload recording to README or future website hero.
