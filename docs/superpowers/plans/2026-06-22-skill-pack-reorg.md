# Skill Pack Reorg Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bound the OSS SkillSteroids agent pack into `packages/skill-pack/` so `install.sh` symlinks a clean pack (not the whole monorepo), web audit loads govern scripts from the pack, and web gains a pack manifest loader for future Pro agent mutation (Option C).

**Architecture:** Monorepo keeps `apps/web/` and root `evals/` (CI source of truth). All agent-facing markdown modules (`orchestrator/`, `governor/`, `evolver/`, `lineage/`, `references/`, `scripts/`) move under `packages/skill-pack/`. `install.sh` symlinks `packages/skill-pack` → `~/.cursor/skills/skill-steroids`. Web uses `getPackRoot()` for bash scripts and `loadSkill()` for embedded SKILL.md prompts. No LLM mutation, auth, or Stripe in this plan.

**Tech Stack:** git mv, bash, TypeScript, Vitest, npm workspaces, Next.js 15

## Global Constraints

- Product shape: Option **C** — free web = deterministic audit; Pro (later) = server agent using same pack prompts; OSS = local install
- Free tier stays deterministic only — no LLM routes in this plan
- Web verdicts must match `govern-check.sh` for all golden fixtures (regression rule from design spec)
- Rebrand paths: `skill-steroids`, `~/.cursor/skills/skill-steroids`
- Do not scope-creep into Phase 2 auth, Phase 3 Stripe/mutation API, or `packages/audit-core` TS port
- Preserve git history via `git mv`, not copy-delete
- `evals/` stays at repo root per design spec

---

## File Map

| Path | Responsibility |
|------|----------------|
| `packages/skill-pack/SKILL.md` | Root agent entry (install target) |
| `packages/skill-pack/orchestrator/` … `lineage/` | Sub-skill modules |
| `packages/skill-pack/principles.md` | Governor constitution |
| `packages/skill-pack/references/` | Run artifacts, schemas, lineage |
| `packages/skill-pack/scripts/` | govern-check, doctor, stats, init-run |
| `packages/skill-pack/templates/` | skill-template.md |
| `packages/skill-pack/package.json` | Pack metadata (`@skillsteroids/skill-pack`) |
| `evals/` | Golden fixtures + harness (repo root, unchanged location) |
| `apps/web/lib/pack/paths.ts` | `getPackRoot()`, `getRepoRoot()` |
| `apps/web/lib/pack/manifest.ts` | Canonical list of pack skill paths |
| `apps/web/lib/pack/load-skill.ts` | Read SKILL.md / principles from pack |
| `apps/web/lib/audit/run-audit.ts` | Modify: use `getPackRoot()` for scripts |
| `install.sh` | Symlink `packages/skill-pack`, not repo root |
| `scripts/doctor.sh` | Move → `packages/skill-pack/scripts/doctor.sh` |
| `evals/run-eval.sh` | Modify: `PACK_ROOT` for govern scripts |

**Delete after move:** duplicate root `skill-template.md` (keep `packages/skill-pack/templates/skill-template.md`)

**Modify (path references):** `README.md`, `INSTALL.md`, `SKILL.md` pack layout table, `CHANGELOG.md`

---

### Task 1: Scaffold packages/skill-pack directory

**Files:**
- Create: `packages/skill-pack/package.json`
- Create: `packages/skill-pack/README.md`

**Interfaces:**
- Produces: empty pack workspace ready for `git mv`

- [ ] **Step 1: Create pack package.json**

Create `packages/skill-pack/package.json`:

```json
{
  "name": "@skillsteroids/skill-pack",
  "version": "2.0.0",
  "private": true,
  "description": "OSS SkillSteroids agent skill pack — orchestrator, governor, evolver, lineage",
  "files": ["**/*.md", "scripts/**", "references/**", "templates/**"]
}
```

- [ ] **Step 2: Create pack README**

Create `packages/skill-pack/README.md`:

```markdown
# SkillSteroids Skill Pack

OSS agent install target. Symlinked to `~/.cursor/skills/skill-steroids` via repo-root `install.sh`.

Do not install this directory manually from the monorepo root — use `./install.sh` at repo root.
```

- [ ] **Step 3: Update root workspaces**

Modify root `package.json` — add `packages/*` to workspaces:

```json
{
  "name": "skillsteroids",
  "private": true,
  "version": "2.0.0",
  "workspaces": ["apps/*", "packages/*"],
  "scripts": {
    "dev": "npm run dev --workspace=@skillsteroids/web",
    "build": "npm run build --workspace=@skillsteroids/web",
    "test:web": "npm run test --workspace=@skillsteroids/web",
    "evals": "./evals/run-eval.sh",
    "doctor": "./packages/skill-pack/scripts/doctor.sh"
  }
}
```

- [ ] **Step 4: Commit scaffold**

```bash
git add packages/skill-pack/package.json packages/skill-pack/README.md package.json
git commit -m "chore: scaffold packages/skill-pack workspace"
```

---

### Task 2: Git mv OSS modules into packages/skill-pack

**Files:**
- Move: `SKILL.md`, `orchestrator/`, `governor/`, `observer/`, `analyzer/`, `evolver/`, `experimenter/`, `lineage/`
- Move: `principles.md`, `metrics.md`, `evolution.md`
- Move: `references/`, `scripts/`, `templates/`
- Delete: root `skill-template.md` (duplicate of `templates/skill-template.md`)

**Interfaces:**
- Produces: all agent modules under `packages/skill-pack/`

- [ ] **Step 1: Move pack files with git mv**

Run from repo root:

```bash
git mv SKILL.md packages/skill-pack/
git mv orchestrator governor observer analyzer evolver experimenter lineage packages/skill-pack/
git mv principles.md metrics.md evolution.md packages/skill-pack/
git mv references scripts templates packages/skill-pack/
git rm skill-template.md 2>/dev/null || rm -f skill-template.md
```

- [ ] **Step 2: Verify pack layout**

```bash
test -f packages/skill-pack/SKILL.md
test -f packages/skill-pack/scripts/govern-check.sh
test -f packages/skill-pack/governor/SKILL.md
test -f packages/skill-pack/references/output-schemas.md
```

Expected: all paths exist.

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "refactor: move OSS skill pack into packages/skill-pack"
```

---

### Task 3: Fix eval harness paths

**Files:**
- Modify: `evals/run-eval.sh`
- Modify: `evals/run-semantic-eval.sh`

**Interfaces:**
- Consumes: `packages/skill-pack/scripts/govern-check.sh`, `govern-semantic-check.sh`
- Produces: eval harness works from repo root with fixtures at `evals/`

- [ ] **Step 1: Update run-eval.sh**

Replace the top of `evals/run-eval.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACK_ROOT="$REPO_ROOT/packages/skill-pack"
GOVERN="$PACK_ROOT/scripts/govern-check.sh"
FAILURES=0
TOTAL=0
```

Replace fixture path resolution — change:

```bash
local full="$ROOT/$path"
```

to:

```bash
local full="$REPO_ROOT/$path"
```

Replace semantic eval invocation at bottom — ensure it uses `PACK_ROOT`:

```bash
chmod +x "$REPO_ROOT/evals/run-semantic-eval.sh" "$PACK_ROOT/scripts/govern-semantic-check.sh"
"$REPO_ROOT/evals/run-semantic-eval.sh" || SEMANTIC_EXIT=$?
```

- [ ] **Step 2: Update run-semantic-eval.sh**

At top of `evals/run-semantic-eval.sh`, replace ROOT with:

```bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACK_ROOT="$REPO_ROOT/packages/skill-pack"
SEMANTIC="$PACK_ROOT/scripts/govern-semantic-check.sh"
```

Update any `$ROOT/` fixture paths to `$REPO_ROOT/`.

- [ ] **Step 3: Run eval harness**

```bash
./evals/run-eval.sh
```

Expected: `Eval harness: PASS (structural + semantic)`

- [ ] **Step 4: Commit**

```bash
git add evals/run-eval.sh evals/run-semantic-eval.sh
git commit -m "fix: point eval harness at packages/skill-pack scripts"
```

---

### Task 4: Update install.sh and doctor

**Files:**
- Modify: `install.sh`
- Modify: `packages/skill-pack/scripts/doctor.sh`

**Interfaces:**
- Produces: `install.sh` symlinks `packages/skill-pack`; doctor validates pack paths

- [ ] **Step 1: Update install.sh SOURCE**

In `install.sh`, replace:

```bash
SOURCE="${SKILL_STEROIDS_HOME:-$REPO_ROOT}"
```

with:

```bash
PACK_DIR="$REPO_ROOT/packages/skill-pack"
SOURCE="${SKILL_STEROIDS_HOME:-$PACK_DIR}"
```

Add validation after `REPO_ROOT` definition:

```bash
if [[ ! -f "$PACK_DIR/SKILL.md" ]]; then
  echo "ERROR: packages/skill-pack not found. Run from SkillSteroids repo root." >&2
  exit 1
fi
```

- [ ] **Step 2: Update doctor.sh pack paths**

In `packages/skill-pack/scripts/doctor.sh`, the existing line:

```bash
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
```

already resolves to `packages/skill-pack` — no change needed.

Update eval runner check path if it says `$ROOT/evals/` — change to repo root:

```bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
check "Eval runner" "$REPO_ROOT/evals/run-eval.sh"
```

Keep all other checks as `$ROOT/SKILL.md`, `$ROOT/governor/SKILL.md`, etc.

- [ ] **Step 3: Run doctor**

```bash
./packages/skill-pack/scripts/doctor.sh
```

Expected: `Doctor: PASS` (CI mode: `CI=true ./packages/skill-pack/scripts/doctor.sh`)

- [ ] **Step 4: Re-run install locally**

```bash
./install.sh
```

Expected: `~/.cursor/skills/skill-steroids` → `packages/skill-pack` (not repo root)

- [ ] **Step 5: Commit**

```bash
git add install.sh packages/skill-pack/scripts/doctor.sh
git commit -m "fix: install.sh symlinks packages/skill-pack only"
```

---

### Task 5: Update root SKILL.md pack layout and docs

**Files:**
- Modify: `packages/skill-pack/SKILL.md` (pack layout table — paths unchanged relative to pack)
- Modify: `README.md`, `INSTALL.md`, `CHANGELOG.md`

- [ ] **Step 1: Add monorepo note to pack SKILL.md**

After the Pack layout table in `packages/skill-pack/SKILL.md`, append:

```markdown
## Monorepo note

When cloned from GitHub, this pack lives at `packages/skill-pack/`. Eval fixtures and the web app live at repo root (`evals/`, `apps/web/`). `install.sh` symlinks this directory only.
```

- [ ] **Step 2: Update README repository structure**

In root `README.md`, replace the repository structure block with:

```markdown
## Repository Structure

```
SkillSteroids/
├── apps/web/                   # MicroSaaS (Next.js)
├── packages/skill-pack/        # OSS agent pack (install target)
│   ├── SKILL.md
│   ├── orchestrator/ … lineage/
│   ├── scripts/                # govern-check, doctor, stats
│   └── references/
├── evals/                      # CI golden fixtures
├── docs/
└── install.sh                  # symlinks packages/skill-pack
```
```

- [ ] **Step 3: Update INSTALL.md paths**

Replace `./scripts/doctor.sh` with `./packages/skill-pack/scripts/doctor.sh` (or `npm run doctor`).

- [ ] **Step 4: Prepend CHANGELOG entry**

```markdown
## [2.1.0] - 2026-06-22

### Changed
- OSS skill pack moved to `packages/skill-pack/` — install symlinks pack only, not monorepo root
- Eval harness and web audit reference pack scripts via `PACK_ROOT`
```

- [ ] **Step 5: Commit**

```bash
git add packages/skill-pack/SKILL.md README.md INSTALL.md CHANGELOG.md
git commit -m "docs: update paths for packages/skill-pack layout"
```

---

### Task 6: Web pack paths — replace repo-root with pack-root

**Files:**
- Create: `apps/web/lib/pack/paths.ts`
- Modify: `apps/web/lib/repo-root.ts` → re-export or deprecate
- Modify: `apps/web/lib/audit/run-audit.ts`
- Modify: `apps/web/next.config.ts`
- Modify: `apps/web/__tests__/run-audit.integration.test.ts`

**Interfaces:**
- Produces: `getPackRoot(): string`, `getRepoRoot(): string`
- Consumes: `getPackRoot()` in `run-audit.ts` for `scripts/` path

- [ ] **Step 1: Write failing path test**

Create `apps/web/__tests__/pack-paths.test.ts`:

```typescript
import { describe, it, expect } from "vitest";
import fs from "fs";
import path from "path";
import { getPackRoot, getRepoRoot } from "@/lib/pack/paths";

describe("pack paths", () => {
  it("getPackRoot resolves to packages/skill-pack with govern script", () => {
    const pack = getPackRoot();
    const govern = path.join(pack, "scripts/govern-check.sh");
    expect(fs.existsSync(govern)).toBe(true);
  });

  it("getRepoRoot resolves to monorepo root with evals", () => {
    const repo = getRepoRoot();
    expect(fs.existsSync(path.join(repo, "evals/run-eval.sh"))).toBe(true);
  });
});
```

- [ ] **Step 2: Run test — expect FAIL**

```bash
cd apps/web && npm run test -- __tests__/pack-paths.test.ts
```

Expected: FAIL — module not found

- [ ] **Step 3: Implement paths.ts**

Create `apps/web/lib/pack/paths.ts`:

```typescript
import path from "path";

/** Monorepo root (evals/, apps/, packages/) */
export function getRepoRoot(): string {
  const fromEnv = process.env.SKILLSTEROIDS_REPO_ROOT;
  if (fromEnv) return fromEnv;
  return path.join(process.cwd(), "../..");
}

/** OSS skill pack (governor, scripts, references) */
export function getPackRoot(): string {
  const fromEnv = process.env.SKILLSTEROIDS_PACK_ROOT;
  if (fromEnv) return fromEnv;
  return path.join(getRepoRoot(), "packages/skill-pack");
}
```

- [ ] **Step 4: Update run-audit.ts**

In `apps/web/lib/audit/run-audit.ts`, replace:

```typescript
import { getRepoRoot } from "@/lib/repo-root";
```

with:

```typescript
import { getPackRoot } from "@/lib/pack/paths";
```

In `runScript`, replace `getRepoRoot()` with `getPackRoot()` and keep `cwd: getPackRoot()`:

```typescript
async function runScript(script: string, args: string[]): Promise<string> {
  const pack = getPackRoot();
  const scriptPath = path.join(pack, "scripts", script);
  try {
    const { stdout, stderr } = await execFileAsync("bash", [scriptPath, ...args], {
      cwd: pack,
      timeout: 30_000,
    });
    return `${stdout}\n${stderr}`;
  } catch (err: unknown) {
    const execErr = err as NodeJS.ErrnoException & { stdout?: string; stderr?: string };
    if (execErr.stdout !== undefined || execErr.stderr !== undefined) {
      return `${execErr.stdout ?? ""}\n${execErr.stderr ?? ""}`;
    }
    throw err;
  }
}
```

- [ ] **Step 5: Update integration test imports**

In `apps/web/__tests__/run-audit.integration.test.ts`:

```typescript
import { getRepoRoot } from "@/lib/pack/paths";
```

- [ ] **Step 6: Update next.config.ts**

```typescript
const repoRoot = path.join(__dirname, "../..");
const packRoot = path.join(repoRoot, "packages/skill-pack");

const nextConfig: NextConfig = {
  experimental: {
    serverActions: { bodySizeLimit: "512kb" },
  },
  env: {
    SKILLSTEROIDS_REPO_ROOT: repoRoot,
    SKILLSTEROIDS_PACK_ROOT: packRoot,
  },
};
```

- [ ] **Step 7: Delete old repo-root.ts**

```bash
rm apps/web/lib/repo-root.ts
```

- [ ] **Step 8: Run all web tests**

```bash
cd apps/web && npm run test
```

Expected: PASS (10 tests — 8 existing + 2 path tests)

- [ ] **Step 9: Commit**

```bash
git add apps/web/lib/pack/paths.ts apps/web/lib/audit/run-audit.ts apps/web/next.config.ts \
  apps/web/__tests__/pack-paths.test.ts apps/web/__tests__/run-audit.integration.test.ts
git rm apps/web/lib/repo-root.ts
git commit -m "feat: web audit uses getPackRoot for govern scripts"
```

---

### Task 7: Pack manifest and load-skill (agent embed foundation)

**Files:**
- Create: `apps/web/lib/pack/manifest.ts`
- Create: `apps/web/lib/pack/load-skill.ts`
- Create: `apps/web/__tests__/load-skill.test.ts`

**Interfaces:**
- Produces: `PACK_MODULES`, `loadSkillMarkdown(relPath: string): string`, `loadPrinciples(): string`
- Consumes: `getPackRoot()` from Task 6

- [ ] **Step 1: Write failing load-skill test**

Create `apps/web/__tests__/load-skill.test.ts`:

```typescript
import { describe, it, expect } from "vitest";
import { loadSkillMarkdown, loadPrinciples, PACK_MODULES } from "@/lib/pack/load-skill";

describe("load-skill", () => {
  it("lists core pack modules", () => {
    expect(PACK_MODULES).toContain("governor/SKILL.md");
    expect(PACK_MODULES).toContain("orchestrator/SKILL.md");
    expect(PACK_MODULES).toContain("evolver/SKILL.md");
  });

  it("loads governor SKILL.md with frontmatter", () => {
    const md = loadSkillMarkdown("governor/SKILL.md");
    expect(md).toMatch(/^---/);
    expect(md).toContain("Governor");
  });

  it("loads principles.md", () => {
    const md = loadPrinciples();
    expect(md).toContain("P-02");
  });
});
```

- [ ] **Step 2: Run test — expect FAIL**

```bash
cd apps/web && npm run test -- __tests__/load-skill.test.ts
```

- [ ] **Step 3: Implement manifest.ts**

Create `apps/web/lib/pack/manifest.ts`:

```typescript
/** Relative paths under packages/skill-pack/ for agent embedding */
export const PACK_MODULES = [
  "SKILL.md",
  "orchestrator/SKILL.md",
  "governor/SKILL.md",
  "observer/SKILL.md",
  "analyzer/SKILL.md",
  "evolver/SKILL.md",
  "experimenter/SKILL.md",
  "lineage/SKILL.md",
  "principles.md",
  "metrics.md",
  "evolution.md",
  "references/output-schemas.md",
] as const;

export type PackModulePath = (typeof PACK_MODULES)[number];
```

- [ ] **Step 4: Implement load-skill.ts**

Create `apps/web/lib/pack/load-skill.ts`:

```typescript
import fs from "fs";
import path from "path";
import { getPackRoot } from "./paths";
import { PACK_MODULES, type PackModulePath } from "./manifest";

export { PACK_MODULES, type PackModulePath };

export function loadSkillMarkdown(relPath: PackModulePath | string): string {
  const full = path.join(getPackRoot(), relPath);
  if (!fs.existsSync(full)) {
    throw new Error(`Pack file not found: ${relPath}`);
  }
  return fs.readFileSync(full, "utf8");
}

export function loadPrinciples(): string {
  return loadSkillMarkdown("principles.md");
}

export function loadOrchestratorPrompt(): string {
  return loadSkillMarkdown("orchestrator/SKILL.md");
}

export function loadGovernorPrompt(): string {
  return loadSkillMarkdown("governor/SKILL.md");
}

export function loadEvolverPrompt(): string {
  return loadSkillMarkdown("evolver/SKILL.md");
}
```

- [ ] **Step 5: Run tests**

```bash
cd apps/web && npm run test
```

Expected: PASS (13 tests)

- [ ] **Step 6: Commit**

```bash
git add apps/web/lib/pack/manifest.ts apps/web/lib/pack/load-skill.ts apps/web/__tests__/load-skill.test.ts
git commit -m "feat: add pack manifest and load-skill for web agent embed"
```

---

### Task 8: CI and final verification

**Files:**
- Modify: `.github/workflows/evals.yml`
- Modify: root `package.json` (if Task 13 web-tests not yet done — add here)

**Interfaces:**
- Consumes: all prior tasks

- [ ] **Step 1: Update CI doctor path**

In `.github/workflows/evals.yml`, replace:

```yaml
run: CI=true ./scripts/doctor.sh
```

with:

```yaml
run: CI=true ./packages/skill-pack/scripts/doctor.sh
```

Add web test job if not present:

```yaml
  web-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "22"
          cache: npm
      - run: npm install
      - run: npm run test --workspace=@skillsteroids/web
```

- [ ] **Step 2: Full verification suite**

```bash
CI=true ./packages/skill-pack/scripts/doctor.sh
./evals/run-eval.sh
cd apps/web && npm run test && npm run build
```

Expected: all PASS

- [ ] **Step 3: Smoke test API still works**

```bash
cd evals/golden-pass/minimal-skill && zip -r /tmp/test-skill.zip . && cd -
# with dev server running:
curl -s -X POST -F "file=@/tmp/test-skill.zip" http://localhost:3000/api/audit | grep -q '"verdict":"PASS"'
```

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/evals.yml
git commit -m "ci: update doctor path and add web tests for pack reorg"
```

---

## Post-plan: what this unlocks (not in scope here)

| Future work | Uses |
|-------------|------|
| Phase 3 `/api/mutate` | `loadEvolverPrompt()`, `loadGovernorPrompt()` |
| Pack zip download on `/docs` | `getPackRoot()` + archiver |
| `packages/audit-core` TS port | Same rules as `scripts/govern-check.sh` |
| Cursor plugin skills path | Point plugin at `packages/skill-pack/SKILL.md` if Cursor adds path config |

---

## Self-Review Checklist

| Spec requirement | Task |
|------------------|------|
| Option C — bounded pack + web agent foundation | Tasks 1–7 |
| OSS install path clean | Task 4 |
| Web audit parity with bash | Tasks 6, 8 |
| evals stay at root | Task 3 |
| No auth/Stripe/mutation | Global Constraints |
| Manifest for embedded agent | Task 7 |

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-06-22-skill-pack-reorg.md`. Two execution options:

**1. Subagent-Driven (recommended)** — fresh subagent per task, spec + quality review between tasks

**2. Inline Execution** — execute in this session using executing-plans, batch with checkpoints

Which approach?
