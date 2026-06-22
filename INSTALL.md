# Install SkillSteroids

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

1. Symlinks `packages/skill-pack` to `~/.cursor/skills/skill-steroids`
2. Optionally symlinks to `~/.agents/skills/skill-steroids` (set `SKILL_STEROIDS_AGENTS=1`)
3. Runs `packages/skill-pack/scripts/doctor.sh` and prints pass/fail

## Verify

```bash
./packages/skill-pack/scripts/doctor.sh
./packages/skill-pack/scripts/stats.sh
./evals/run-eval.sh
```

In a new Cursor agent chat: **"run skill steroids"**

## Uninstall

```bash
./install.sh --uninstall
```

## Environment variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `SKILL_STEROIDS_HOME` | clone path | Override source directory |
| `SKILL_STEROIDS_CURSOR` | `~/.cursor/skills/skill-steroids` | Cursor install target |
| `SKILL_STEROIDS_AGENTS` | unset | Set `1` to also install under `~/.agents/skills` |

## Agent support

| Agent | Install path | Trigger |
|-------|--------------|---------|
| Cursor | `~/.cursor/skills/skill-steroids/` | "run skill steroids" |
| Claude Code / agents dir | `~/.agents/skills/skill-steroids/` | same |
| Claude desktop skills | `~/.claude/skills/skill-steroids/` | optional, `--with-claude` flag |

## External dependencies (recommended)

| Skill | Path | Required for |
|-------|------|--------------|
| skill-architect | `~/.agents/skills/skill-architect/SKILL.md` | Evolver create path |
| skill-destroyer | install separately | Analyzer deep review |

Run `./packages/skill-pack/scripts/doctor.sh` to check. Fallback rubric ships in `packages/skill-pack/references/skill-destroyer-rubric.md`.
