# Install Skill Botox

## Quick install (macOS / Linux / WSL)

```bash
curl -fsSL https://raw.githubusercontent.com/arkitectco/SkillBotox/main/install.sh | bash
```

Or from a local clone:

```bash
git clone https://github.com/arkitectco/SkillBotox.git
cd SkillBotox
./install.sh
```

## What install does

1. Symlinks this repo to `~/.cursor/skills/skill-botox`
2. Optionally symlinks to `~/.agents/skills/skill-botox` (set `SKILL_BOTOX_AGENTS=1`)
3. Runs `scripts/doctor.sh` and prints pass/fail

## Verify

```bash
./scripts/doctor.sh
./scripts/stats.sh
./evals/run-eval.sh
```

In a new Cursor agent chat: **"run skill botox"**

## Uninstall

```bash
./install.sh --uninstall
```

## Environment variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `SKILL_BOTOX_HOME` | clone path | Override source directory |
| `SKILL_BOTOX_CURSOR` | `~/.cursor/skills/skill-botox` | Cursor install target |
| `SKILL_BOTOX_AGENTS` | unset | Set `1` to also install under `~/.agents/skills` |

## Agent support

| Agent | Install path | Trigger |
|-------|--------------|---------|
| Cursor | `~/.cursor/skills/skill-botox/` | "run skill botox" |
| Claude Code / agents dir | `~/.agents/skills/skill-botox/` | same |
| Claude desktop skills | `~/.claude/skills/skill-botox/` | optional, `--with-claude` flag |

## External dependencies (recommended)

| Skill | Path | Required for |
|-------|------|--------------|
| skill-architect | `~/.agents/skills/skill-architect/SKILL.md` | Evolver create path |
| skill-destroyer | install separately | Analyzer deep review |

Run `./scripts/doctor.sh` to check. Fallback rubric ships in `references/skill-destroyer-rubric.md`.
