# Install SkillSteroids

## Plugin install (recommended)

| Platform | Install |
|----------|---------|
| Cursor | Install **skill-steroids** from Cursor marketplace, or open this repo as a local plugin |
| Claude Code | `/plugin marketplace add arkitectco/SkillBotox` then install **skill-steroids** (source is `./plugin`) |
| Grok Build | `grok plugin install arkitectco/SkillBotox#plugin --trust` |
| Codex | Install from Codex plugin registry after publish, or `./install.sh --with-codex` |

**Plugin bootstrap:** Cursor, Claude, and Codex plugin installs inject `using-skill-steroids` at session start — agents learn trigger phrases automatically. Symlink install (`./install.sh`) does not inject hooks; optionally paste the bootstrap snippet below into a user rule or `AGENTS.md`.

### Symlink bootstrap snippet (optional)

After multi-step work, if skill friction occurred, suggest: **"skill steroids audit"** with 1–3 friction bullets. Load full `skill-steroids` only when the user asks for audit or mutation.

## Symlink install (OSS fallback)

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

1. Symlinks `plugin/skills/skill-steroids` to `~/.cursor/skills/skill-steroids`
2. Optionally symlinks to `~/.agents/skills/skill-steroids` (set `SKILL_STEROIDS_AGENTS=1`)
3. Runs `plugin/skills/skill-steroids/scripts/doctor.sh` and prints pass/fail

## Verify

```bash
./plugin/skills/skill-steroids/scripts/doctor.sh
./plugin/skills/skill-steroids/scripts/stats.sh
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
| Codex | `$CODEX_HOME/skills/skill-steroids/` or `~/.agents/skills/skill-steroids/` | same triggers |

## External dependencies (recommended)

| Skill | Path | Required for |
|-------|------|--------------|
| skill-architect | `~/.agents/skills/skill-architect/SKILL.md` | Evolver create path |
| skill-destroyer | install separately | Analyzer deep review |

Run `./plugin/skills/skill-steroids/scripts/doctor.sh` to check. Fallback rubric ships in `plugin/skills/skill-steroids/references/skill-destroyer-rubric.md`.
