# Using SkillSteroids Session Bootstrap — Design Spec

**Status:** Approved (brainstorming 2026-06-27)  
**Builds on:** Plugin distribution spec (2026-06-24), `packages/skill-pack/`  
**Supersedes:** Plugin distribution decision "Hooks deferred — post-session reminder stays markdown-only" for SessionStart bootstrap only

---

## Summary

Add a Superpowers-style session bootstrap so SkillSteroids is **awareness-injected every session** but **only runs the full audit/mutate loop on explicit user request**.

- New lightweight skill: `packages/skill-pack/using-skill-steroids/SKILL.md`
- New hooks under `packages/skill-pack/hooks/` (Cursor, Claude, Codex)
- Thin plugin manifests gain a `hooks` field pointing at pack hooks
- Root `skill-steroids` entry skill unchanged (`disable-model-invocation: true`)

**Not in scope:** post-turn hooks, MCP, orchestrator logic changes, automated publish, web/evals in plugin artifacts.

---

## Problem

Without session injection, an installed SkillSteroids plugin is dead weight until the user remembers trigger phrases. Superpowers solves this with `using-superpowers` + SessionStart hooks. SkillSteroids deferred hooks in the plugin distribution release; users must manually invoke `"run skill steroids"`.

SkillSteroids differs from Superpowers: it must **not** influence every coding turn — only teach **when** to load the heavy framework.

---

## Decisions log

| Topic | Decision |
|-------|----------|
| Initiation model | Session bootstrap (Superpowers-style) — inject bootstrap every session |
| Platforms | Cursor + Claude Code + Codex in one release |
| Layout | All bootstrap + hook files inside `packages/skill-pack/` |
| Bootstrap content | **B** — triggers + friction nudge + one-line "when NOT to invoke" |
| Implementation approach | Superpowers clone — adapt hook scripts, change paths and injected content |
| Heavy entry skill | Root `SKILL.md` stays `disable-model-invocation: true` |
| Symlink install | Hooks fire only for plugin installs; docs snippet for optional user-rule paste |
| Version | **2.3.0** (via `bump-plugin-version.sh`) |

---

## Architecture

```
packages/skill-pack/
├── SKILL.md                         # heavy entry (disable-model-invocation: true)
├── using-skill-steroids/
│   └── SKILL.md                     # lightweight bootstrap (~40–60 lines)
└── hooks/
    ├── hooks-cursor.json
    ├── hooks.json                   # Claude
    ├── hooks-codex.json
    ├── run-hook.cmd
    ├── session-start                # Cursor + Claude
    └── session-start-codex
```

### Session flow

1. **SessionStart** → hook reads `using-skill-steroids/SKILL.md` → injects into agent context
2. Agent has awareness of triggers and friction nudge — **does not** run orchestrator
3. User says `"skill steroids audit"` → agent loads `skill-steroids` via platform skill tool → full loop

### Manifest wiring

| Platform | Manifest | Hooks path |
|----------|----------|------------|
| Cursor | `.cursor-plugin/plugin.json` | `"hooks": "../packages/skill-pack/hooks/hooks-cursor.json"` |
| Claude | `.claude-plugin/plugin.json` | `"hooks": "../packages/skill-pack/hooks/hooks.json"` |
| Codex | `.codex-plugin/plugin.json` | `"hooks": "../packages/skill-pack/hooks/hooks-codex.json"` |

Paths are relative to each manifest directory (same pattern as `skills` field).

### Codex sync

Hooks ship automatically: `sync-to-codex-plugin.sh` rsyncs `packages/skill-pack/` to fork `plugins/skill-steroids/`. Verify dry-run includes `hooks/` and `using-skill-steroids/`; no sync script logic change expected beyond verification.

---

## Bootstrap skill — `using-skill-steroids`

**Path:** `packages/skill-pack/using-skill-steroids/SKILL.md`

| Frontmatter | Value |
|-------------|-------|
| `name` | `using-skill-steroids` |
| `description` | Establishes when/how to invoke SkillSteroids for skill library audit or mutation |
| `disable-model-invocation` | omitted — not auto-loaded by model; injected via hook only |

### Content sections

1. **Purpose** — orientation only; not the full framework
2. **When to invoke `skill-steroids`**

   | User intent | Phrases | Mode |
   |-------------|---------|------|
   | Health report | "run skill steroids", "skill steroids audit", "skill library health" | audit |
   | Governed change | "skill steroids mutate", "evolve skill X" | mutate |

3. **When NOT to invoke** — normal feature work, bugs, refactors ≠ skill library evolution
4. **How to invoke** — use platform skill-loading mechanism for `skill-steroids`; do not manually read orchestrator/governor files
5. **Post-session friction nudge** — after 3+ tool calls or 1+ file write, if skill friction occurred (wrong skill loaded, repeated explanations, manual overrides), suggest `"skill steroids audit"` and ask for 1–3 friction bullets. Suggestion only; never auto-run the loop
6. **Subagent carve-out** — `<SUBAGENT-STOP>` block: skip if dispatched as subagent for unrelated work (mirror Superpowers)

### Relationship to root skill

| Skill | Role | Session injection |
|-------|------|-------------------|
| `using-skill-steroids` | Bootstrap / when-to-invoke | Yes (hook) |
| `skill-steroids` | Full orchestrator entry | No — user-triggered only |

Avoid duplicating orchestrator modes, Governor rules, or scope tables in bootstrap — those live in root `SKILL.md` and `orchestrator/SKILL.md` to prevent drift.

---

## Hook behavior

Adapted from Superpowers 6.0.3. `PLUGIN_ROOT` = parent of `hooks/` (= pack root).

| File | Behavior |
|------|----------|
| `session-start` | Read bootstrap SKILL.md, JSON-escape, wrap in `<EXTREMELY_IMPORTANT>`. Platform output: Cursor → `additional_context`; Claude → `hookSpecificOutput`; default/Copilot → `additionalContext` |
| `session-start-codex` | Same content; Codex `hookSpecificOutput` schema |
| `run-hook.cmd` | Cross-platform polyglot wrapper (copy from Superpowers) |
| `hooks-cursor.json` | `sessionStart` → `./hooks/run-hook.cmd session-start` (path relative to pack hooks dir as resolved by platform) |
| `hooks.json` | Claude: matcher `startup\|clear\|compact` |
| `hooks-codex.json` | Codex: matcher `startup\|resume\|clear` |

### Injection preamble

> You have SkillSteroids installed. Below is `using-skill-steroids` — when to invoke the full framework. Load `skill-steroids` only when the user asks for audit or mutation.

### Failure mode

If bootstrap file is missing or unreadable, hook exits 0 silently. Plugin remains functional; user must remember trigger phrases.

---

## Install paths

| Install method | Bootstrap behavior |
|----------------|-------------------|
| Cursor / Claude / Codex plugin | SessionStart hook injects bootstrap |
| `./install.sh` symlink | No hook — optional `INSTALL.md` snippet to paste bootstrap into user rule or `AGENTS.md` |

---

## Verification

| Check | Pass criteria |
|-------|---------------|
| Bootstrap exists | `using-skill-steroids/SKILL.md` present with trigger table |
| Hook files | All six hook files present under `packages/skill-pack/hooks/` |
| Manifest hooks field | All three plugin manifests reference correct hook JSON paths |
| `verify-plugin-manifests.sh` | Extended to validate hook JSON + bootstrap skill |
| Hook smoke test | `tests/hooks/test-session-start.sh` — output contains audit trigger phrase and `<EXTREMELY_IMPORTANT>` |
| Sync dry-run | Preview includes `hooks/` and `using-skill-steroids/`; no `apps/web` |
| Doctor + evals | Unchanged PASS |
| Version | All five bump targets at **2.3.0** |

---

## Documentation updates

| File | Change |
|------|--------|
| `CHANGELOG.md` | `[2.3.0]` — session bootstrap + multi-platform hooks |
| `INSTALL.md` | Plugin install gets automatic bootstrap; symlink users get optional user-rule snippet |
| `README.md` | Note SessionStart bootstrap for plugin installs |
| `docs/PUBLISHING.md` | Mention hooks ship with pack; verify hook smoke test in release checklist |

---

## Out of scope

- Post-turn / post-session **hooks** (friction nudge stays text in bootstrap only)
- Changing orchestrator, Governor, or evolver logic
- Removing `disable-model-invocation` from root `skill-steroids`
- Universal `agents-plugin.json`
- Automated CI publish

---

## Self-review checklist

| Item | Status |
|------|--------|
| No TBD / placeholder sections | ✓ |
| Consistent with pack-only ship unit | ✓ |
| Codex sync compatibility | ✓ — hooks inside pack |
| Does not duplicate orchestrator content | ✓ |
| Supersedes prior "hooks deferred" explicitly | ✓ |
| Scoped for single implementation plan | ✓ |
