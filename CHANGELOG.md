# Changelog

All notable changes to SkillSteroids are documented here.

## [Unreleased]

### Changed
- Removed OSS standalone pack install (`install.sh` / `~/.cursor/skills` symlink). Plugin marketplace is the only install path
- P-02 structural check accepts situation cues beyond "Use when" (use for / trigger / quoted phrases)
- Doctor PASSes on pack/plugin-root; Cursor `~/.cursor/skills` symlink is optional leftover
- Manifest check fails on version, description, and command-count drift (`package.json` excluded from plugin version)
- Removed pack `hooks/hooks.json`; Claude/Grok SessionStart uses `plugin/hooks/hooks.json` only
- Root `SKILL.md` activation is host-neutral; slash commands stay in `plugin/commands/`
- Grok manifest declares `skills`, `commands`, and `hooks`
- README current version is 2.3.1; getting started points at INSTALL.md instead of HANDOFFER.md
- Create/review stay in-plugin (no skill-architect / skill-destroyer deps)
- Collapsed the OSS skill pack into `plugin/skills/skill-steroids` (removed the `packages/skill-pack` dual tree)
- Slim `plugin/` install surface (Impeccable-style): `skills/skill-steroids`, `commands/`, `hooks/`, `.claude-plugin` + `.grok-plugin`
- Claude marketplace `source` is `./plugin` (no longer the monorepo root)
- Hook commands resolve via `${CLAUDE_PLUGIN_ROOT}` inside the plugin package
- Entry skill is user-invocable (`/skill-steroids [audit|mutate]`); bootstrap skill is not

## [2.3.1] - 2026-09-05

### Changed
- Experimenter step 7 grafts onto the winner's architecture (shape + wire-in + overlap); reject flatten; majority win still takes the loser's leftover

## [2.3.0] - 2026-06-27

### Added
- `using-skill-steroids` session bootstrap skill (triggers + friction nudge)
- SessionStart hooks for Cursor, Claude, and Codex (`packages/skill-pack/hooks/`)
- Hook smoke tests (`tests/hooks/test-session-start.sh`)

### Changed
- Plugin manifests include `hooks` field pointing at pack hooks
- Plugin installs inject bootstrap every session; symlink install unchanged

## [2.2.0] - 2026-06-24

### Added
- Multi-platform plugin manifests (Cursor, Claude, Codex) pointing at `packages/skill-pack/`
- `scripts/bump-plugin-version.sh`, `scripts/sync-to-codex-plugin.sh`, `scripts/verify-plugin-manifests.sh`
- `docs/PUBLISHING.md` release checklist

### Changed
- Plugin-first install docs; `install.sh` adds `--with-codex` for `$CODEX_HOME/skills/`

## [2.1.0] - 2026-06-22

### Changed
- OSS skill pack moved to `packages/skill-pack/` — install symlinks pack only, not monorepo root
- Eval harness and web audit reference pack scripts via `PACK_ROOT`

## [2.0.0] - 2026-06-16

### Added
- SkillSteroids MicroSaaS Phase 1: `apps/web` landing + free audit studio

### Changed
- Rebrand Skill Botox → SkillSteroids
- Install path: `~/.cursor/skills/skill-steroids`
- Agent triggers: `skill steroids audit` / `skill steroids mutate`

## [1.2.0] - 2026-06-16

### Added

- Run artifacts: `references/runs/`, `scripts/init-run.sh`
- Semantic Governor heuristics: `scripts/govern-semantic-check.sh`
- Semantic eval golden fixtures and `evals/run-semantic-eval.sh`
- Audit vs mutate orchestrator modes
- Post-session hook snippet: `references/hooks/post-session-reminder.md`
- Falsification test protocol: `docs/demo-audit.md`

### Changed

- Dual headline metrics in `stats.sh` and `metrics.md`
- Observer requires explicit friction input
- Analyzer capped at 5 deep reviews / 3 proposals
- README honest v1 positioning
- Removed weekly automation claim from `evolution.md`

## [1.1.0] - 2026-06-15

### Added

- Phase A trust layer: `install.sh`, `scripts/doctor.sh`, eval harness, `scripts/stats.sh`
- `INSTALL.md` with agent install matrix
- Golden fixture evals for Governor structural rules
- GitHub Actions CI for evals

### Changed

- Restored MIT LICENSE
- Extended skill inventory paths for Cursor layout

## [1.0.0] - 2026-06-15

### Added

- Initial skill pack: Orchestrator, Governor, Observer, Analyzer, Evolver, Experimenter, Lineage
- `principles.md`, `metrics.md`, `evolution.md` constitution files
- Cursor plugin manifest (`.cursor-plugin/plugin.json`)
