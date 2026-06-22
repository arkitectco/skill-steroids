# Changelog

All notable changes to SkillSteroids are documented here.

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
