# SkillSteroids

npm workspaces monorepo: markdown skill pack (`plugin/skills/skill-steroids`) + Next.js audit studio (`apps/web`). Repo folder is `skill-steroids`; product/plugin name is SkillSteroids.

## Rules

- Never write or delete a skill file without Governor PASS/WARN and explicit user approval. Audit mode is reports only.
- Pack skills are markdown-first. Add a script only when markdown cannot scan, log, or validate.
- Do not paste another skill's body into a new skill (P-04). Delegate by name.
- Meta skills must keep `disable-model-invocation: true`.
- Persist every audit/mutate run to `.skill-steroids/runs/<run-id>.md` in the invoking project (not the pack source tree). `init-run.sh` resolves the project root via git or `$SKILL_STEROIDS_PROJECT_ROOT`.
- Do not invoke experimenter in the default loop.

## Stack

| Layer | Technology |
|-------|------------|
| Pack | Markdown `SKILL.md` + bash (`set -euo pipefail`) |
| Web | TypeScript (strict), Next.js 15 App Router, React 19 |
| Tests | Vitest (`apps/web`), bash eval harness (`evals/`) |
| CI | GitHub Actions (`.github/workflows/evals.yml`) |
| Deploy | Vercel (`apps/web/vercel.json`) |
| Package manager | npm workspaces (`package-lock.json`) |

No ESLint/Prettier config in-repo. Could not determine a lint command.

Plugin version source of truth: `.cursor-plugin/plugin.json` and `plugin/.claude-plugin/plugin.json` (currently 2.3.0). Root `package.json` is 2.0.0 and lags.

## Commands

```bash
npm install
npm run dev                          # Next.js studio, http://localhost:3000
npm run build                        # web production build
npm run test:web                     # vitest run
npm run evals                        # structural golden fixtures
./plugin/skills/skill-steroids/scripts/doctor.sh   # pack health (plugin-root or pack checkout PASSes; Cursor symlink optional)
./evals/run-semantic-eval.sh
./tests/hooks/test-session-start.sh
./scripts/verify-plugin-manifests.sh
./plugin/skills/skill-steroids/scripts/stats.sh
# grok plugin install arkitectco/skill-steroids#plugin --trust
```

CI runs `./plugin/skills/skill-steroids/scripts/doctor.sh` (pack/plugin-root PASSes without a Cursor symlink).

## Structure

| Path | Purpose |
|------|---------|
| `plugin/skills/skill-steroids/` | Skill pack. Orchestrator → Observer → Analyzer → Governor → Evolver → Lineage |
| `plugin/skills/skill-steroids/principles.md` | Constitution. Governor enforces P-01–P-08 |
| `plugin/skills/skill-steroids/scripts/` | `doctor`, `govern-check`, `govern-semantic-check`, `init-run`, `stats` |
| `apps/web/` | Landing, `/studio` zip upload, `POST /api/audit` |
| `evals/` | Golden pass/fail fixtures for govern scripts |
| `plugin/` | Marketplace install surface (`skills/skill-steroids`, commands, hooks) |
| `.cursor-plugin/`, `.claude-plugin/`, `.codex-plugin/` | Root manifests. Claude marketplace `source` is `./plugin` |
| `docs/` | PRD, vision, publishing. `HANDOFFER.md` is a stale June 2026 scaffold — ignore for current work |

## Web audit path

`SkillDropzone` POSTs a zip to `/api/audit` → `runAuditFromZip` extracts (max 500KB, 1 skill) → `govern-check.sh` + `govern-semantic-check.sh` via `execFile` → JSON `{ PASS \| WARN \| BLOCK }`. Rate-limited. Pack root comes from `SKILLSTEROIDS_PACK_ROOT` (set in `apps/web/next.config.ts`).

## Code style

- Web files: kebab-case (`parse-govern.ts`); components PascalCase (`VerdictBadge.tsx`).
- Tests: `apps/web/__tests__/*.test.ts` (Vitest, node env, `@/` alias).
- Skills: `SKILL.md` in kebab-case dirs; YAML frontmatter `name` / `description` / `version`.
- Scripts: kebab-case `.sh`.
- Errors: API returns `{ error }` with 400/429; scripts `set -euo pipefail` and print PASS/FAIL lines.
- Imports: direct, no DI. Path alias `@/*` → `apps/web/*`.

## Git

Conventional commits: `feat:`, `fix:`, `docs:`, `chore:`, `ci:`. Feature branches `feat/<name>`. No in-repo formatter; keep diffs small and principled.

## Boundaries

- User-facing docs: `README.md`, `INSTALL.md`, `docs/PUBLISHING.md`.
- Agent loop spec: `plugin/skills/skill-steroids/SKILL.md` then `orchestrator/SKILL.md`.
- Session bootstrap only (not the full loop): `plugin/skills/skill-steroids/using-skill-steroids/SKILL.md`.
- In-plugin create/review: `templates/skill-template.md` + `references/skill-authoring.md`; review via `references/skill-review-rubric.md`. No OSS skill-pack install.
