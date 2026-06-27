# SkillSteroids Plugin Distribution — Design Spec

**Status:** Approved (brainstorming 2026-06-24)  
**Builds on:** `packages/skill-pack/` reorg (2026-06-22), MicroSaaS design spec  
**Scope:** Near-term plugin delivery — Cursor, Claude Code, Codex — all three marketplaces

---

## Summary

Ship SkillSteroids as a proper multi-platform plugin while keeping `packages/skill-pack/` as the single source of truth. Root manifests (`.cursor-plugin/`, `.claude-plugin/`, `.codex-plugin/`) point at the pack. A Superpowers-style `sync-to-codex-plugin.sh` rsyncs pack-only content into a Codex registry fork. `install.sh` remains the OSS symlink fallback for local dev and tools that read `~/.agents/skills/`.

**Not in scope:** Universal `agents-plugin.json` standard, session hooks, MCP bundling, automated CI publish, web app in plugin artifacts.

---

## Decisions log

| Topic | Decision |
|-------|----------|
| Scope | Cursor + Claude Code + Codex |
| Marketplaces | All three registries (publish, not local-only) |
| Distribution model | Superpowers-style sync (C) — monorepo source of truth; Codex via rsync to fork |
| Pack layout | Thin manifests point at `packages/skill-pack/` — no duplicate skills tree in repo |
| Hooks | Deferred — post-session reminder stays markdown-only |
| Version | Unified bump across 3 plugin manifests + `packages/skill-pack/package.json` → **2.2.0** for plugin release |

---

## Architecture

```
SkillBotox/
├── packages/skill-pack/          # canonical content
├── .cursor-plugin/plugin.json    → skills: "../packages/skill-pack/"
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── .codex-plugin/plugin.json     → skills: "../packages/skill-pack/"
├── install.sh                    # symlink fallback
└── scripts/
    ├── bump-plugin-version.sh
    └── sync-to-codex-plugin.sh   # → fork plugins/skill-steroids/
```

### Distribution matrix

| Target | Mechanism |
|--------|-----------|
| Local dev | `./install.sh` (+ `SKILL_STEROIDS_AGENTS=1`, `--with-claude`) |
| Cursor marketplace | Repo publish; manifest skills path → pack |
| Claude marketplace | `marketplace.json` + plugin install |
| Codex registry | `sync-to-codex-plugin.sh` → `plugins/skill-steroids/` on fork |

### Codex sync layout

Rsync `packages/skill-pack/` contents into `plugins/skill-steroids/` on the registry fork. Copy `.codex-plugin/` into that directory. Exclude `apps/web/`, `evals/`, `docs/`, monorepo root files.

The pack uses a **single root `SKILL.md`** with internal sub-modules (`orchestrator/`, `governor/`, …) — not a `skills/` multi-skill tree like Superpowers. Manifest `"skills": "../packages/skill-pack/"` treats the pack directory as the skill content root.

---

## Manifest requirements

### Shared metadata

- `name`: `skill-steroids`
- `version`: synced via `.version-bump.json`
- `description`: Governed audit and mutation for agent skill libraries
- `homepage` / `repository`: `https://github.com/arkitectco/SkillBotox`
- `license`: MIT
- `keywords`: skills, governance, audit, evolution, meta

### Cursor (`.cursor-plugin/plugin.json`)

- `displayName`: SkillSteroids
- `skills`: `../packages/skill-pack/`

### Claude (`.claude-plugin/`)

- `plugin.json`: same core fields
- `marketplace.json`: marketplace `skill-steroids-dev` listing plugin at `./`

### Codex (`.codex-plugin/plugin.json`)

- `skills`: `../packages/skill-pack/`
- `interface` block: displayName, category `Coding`, defaultPrompt entries for audit/mutate triggers

---

## Versioning

`.version-bump.json` declares:

- `.cursor-plugin/plugin.json` → `version`
- `.claude-plugin/plugin.json` → `version`
- `.codex-plugin/plugin.json` → `version`
- `.claude-plugin/marketplace.json` → `plugins.0.version`
- `packages/skill-pack/package.json` → `version`

`scripts/bump-plugin-version.sh` wraps jq updates + `--check` drift detection.

---

## Release process (manual v1)

1. `./scripts/bump-plugin-version.sh 2.2.0`
2. `CI=true ./packages/skill-pack/scripts/doctor.sh`
3. `./evals/run-eval.sh`
4. Merge to `main`
5. Cursor: update marketplace listing
6. Claude: marketplace publish
7. `./scripts/sync-to-codex-plugin.sh` (requires fork + `gh` auth)

Document in `docs/PUBLISHING.md`.

---

## Verification

| Check | Pass criteria |
|-------|---------------|
| Manifest paths | All three resolve to pack with `SKILL.md` + `scripts/govern-check.sh` |
| Sync dry-run | No `apps/web`, `evals/`, or `node_modules` in output |
| `install.sh` | Symlink → `packages/skill-pack` only |
| Doctor + evals | Unchanged PASS |

---

## Post-plan unlocks (not here)

- Session hooks (Cursor/Codex)
- CI automated publish
- Universal `agents-plugin.json`
- Plugin zip download on `/docs`
