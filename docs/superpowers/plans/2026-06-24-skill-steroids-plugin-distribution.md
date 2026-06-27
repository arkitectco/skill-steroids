# SkillSteroids Plugin Distribution Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship SkillSteroids as installable plugins on Cursor, Claude Code, and Codex marketplaces, with thin root manifests pointing at `packages/skill-pack/` and a Superpowers-style Codex sync script.

**Architecture:** Monorepo stays source of truth. `.cursor-plugin/`, `.claude-plugin/`, and `.codex-plugin/` manifests reference `../packages/skill-pack/` as the skills root. `scripts/bump-plugin-version.sh` + `.version-bump.json` keep versions in sync. `scripts/sync-to-codex-plugin.sh` rsyncs pack-only content to `plugins/skill-steroids/` on a Codex registry fork. `install.sh` remains symlink fallback; docs updated for plugin-first install.

**Tech Stack:** bash, jq, rsync, gh CLI, JSON manifests

## Global Constraints

- Pack content lives only in `packages/skill-pack/` — do not duplicate skills into plugin dirs in the monorepo
- Plugin artifacts must NOT include `apps/web/`, `evals/`, or `node_modules`
- Hooks deferred — no `hooks-cursor.json` or `hooks-codex.json` in this plan
- Unified plugin version **2.2.0** for this release (distinct from pack reorg 2.1.0 changelog entry)
- Rebrand paths unchanged: `skill-steroids`, `~/.cursor/skills/skill-steroids`
- Codex sync fork default: `arkitectco/openai-codex-plugins` (must be forked from OpenAI registry before first sync)
- Preserve existing doctor + eval harness PASS — no regressions

---

## File Map

| Path | Responsibility |
|------|----------------|
| `.version-bump.json` | Declares all version fields to sync |
| `scripts/bump-plugin-version.sh` | Bump/check/audit plugin versions |
| `.cursor-plugin/plugin.json` | Cursor marketplace manifest |
| `.claude-plugin/plugin.json` | Claude plugin manifest |
| `.claude-plugin/marketplace.json` | Claude marketplace listing |
| `.codex-plugin/plugin.json` | Codex registry manifest + interface block |
| `scripts/sync-to-codex-plugin.sh` | Rsync pack → Codex fork PR |
| `scripts/verify-plugin-manifests.sh` | CI/local check manifest paths resolve |
| `docs/PUBLISHING.md` | Release checklist for all three marketplaces |
| `INSTALL.md`, `README.md`, `CHANGELOG.md` | Plugin-first install docs |
| `install.sh` | Add `--with-codex` optional symlink to `$CODEX_HOME/skills` |

---

### Task 1: Version bump infrastructure

**Files:**
- Create: `.version-bump.json`
- Create: `scripts/bump-plugin-version.sh`

**Interfaces:**
- Produces: `scripts/bump-plugin-version.sh --check`, `scripts/bump-plugin-version.sh 2.2.0`

- [ ] **Step 1: Create `.version-bump.json`**

Create `.version-bump.json`:

```json
{
  "files": [
    { "path": "packages/skill-pack/package.json", "field": "version" },
    { "path": ".cursor-plugin/plugin.json", "field": "version" },
    { "path": ".claude-plugin/plugin.json", "field": "version" },
    { "path": ".codex-plugin/plugin.json", "field": "version" },
    { "path": ".claude-plugin/marketplace.json", "field": "plugins.0.version" }
  ],
  "audit": {
    "exclude": [
      "CHANGELOG.md",
      "node_modules",
      ".git",
      ".version-bump.json",
      "scripts/bump-plugin-version.sh",
      "package-lock.json"
    ]
  }
}
```

- [ ] **Step 2: Create `scripts/bump-plugin-version.sh`**

Create `scripts/bump-plugin-version.sh` (adapt from Superpowers — requires `jq`):

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG="$REPO_ROOT/.version-bump.json"

read_json_field() {
  local file="$1" field="$2"
  local jq_path
  jq_path=$(echo "$field" | sed -E 's/\.([0-9]+)/[\1]/g' | sed 's/^/./')
  jq -r "$jq_path" "$file"
}

write_json_field() {
  local file="$1" field="$2" value="$3"
  local jq_path
  jq_path=$(echo "$field" | sed -E 's/\.([0-9]+)/[\1]/g' | sed 's/^/./')
  local tmp="${file}.tmp"
  jq "$jq_path = \"$value\"" "$file" > "$tmp" && mv "$tmp" "$file"
}

cmd_check() {
  echo "Version check:"
  local has_drift=0
  while IFS=$'\t' read -r path field; do
    local fullpath="$REPO_ROOT/$path"
    if [[ ! -f "$fullpath" ]]; then
      echo "  MISSING: $path ($field)"
      has_drift=1
      continue
    fi
    echo "  $path ($field): $(read_json_field "$fullpath" "$field")"
  done < <(jq -r '.files[] | "\(.path)\t\(.field)"' "$CONFIG")
  [[ $has_drift -eq 0 ]] || exit 1
}

cmd_bump() {
  local new_ver="$1"
  while IFS=$'\t' read -r path field; do
    write_json_field "$REPO_ROOT/$path" "$field" "$new_ver"
    echo "✓ $path → $new_ver"
  done < <(jq -r '.files[] | "\(.path)\t\(.field)"' "$CONFIG")
}

case "${1:-}" in
  --check) cmd_check ;;
  "") echo "Usage: bump-plugin-version.sh <version> | --check" >&2; exit 1 ;;
  *) cmd_bump "$1" ;;
esac
```

```bash
chmod +x scripts/bump-plugin-version.sh
```

- [ ] **Step 3: Run check (expect MISSING for not-yet-created manifests)**

```bash
./scripts/bump-plugin-version.sh --check
```

Expected: reports MISSING for `.claude-plugin/`, `.codex-plugin/` until Task 2–4.

- [ ] **Step 4: Commit**

```bash
git add .version-bump.json scripts/bump-plugin-version.sh
git commit -m "chore: add plugin version bump infrastructure"
```

---

### Task 2: Cursor plugin manifest

**Files:**
- Modify: `.cursor-plugin/plugin.json`

**Interfaces:**
- Produces: Cursor-loadable manifest with `"skills": "../packages/skill-pack/"`

- [ ] **Step 1: Replace `.cursor-plugin/plugin.json`**

```json
{
  "name": "skill-steroids",
  "displayName": "SkillSteroids",
  "version": "2.2.0",
  "description": "Governed audit and mutation for your AI agent skill library. Orchestrates observation, analysis, governance, and governed evolution.",
  "author": {
    "name": "arkitectco",
    "url": "https://github.com/arkitectco"
  },
  "homepage": "https://github.com/arkitectco/SkillBotox",
  "repository": "https://github.com/arkitectco/SkillBotox",
  "license": "MIT",
  "keywords": [
    "skills",
    "governance",
    "audit",
    "evolution",
    "meta",
    "agent"
  ],
  "skills": "../packages/skill-pack/"
}
```

- [ ] **Step 2: Verify pack path resolves from manifest dir**

```bash
test -f .cursor-plugin/../packages/skill-pack/SKILL.md
test -f packages/skill-pack/scripts/govern-check.sh
echo "Cursor manifest paths: OK"
```

- [ ] **Step 3: Commit**

```bash
git add .cursor-plugin/plugin.json
git commit -m "feat: wire Cursor plugin manifest to skill pack"
```

---

### Task 3: Claude plugin manifest + marketplace

**Files:**
- Create: `.claude-plugin/plugin.json`
- Create: `.claude-plugin/marketplace.json`

**Interfaces:**
- Produces: Claude marketplace-ready plugin listing

- [ ] **Step 1: Create `.claude-plugin/plugin.json`**

```json
{
  "name": "skill-steroids",
  "description": "Governed audit and mutation for your AI agent skill library. Use when the user says run skill steroids, skill steroids audit, or skill steroids mutate.",
  "version": "2.2.0",
  "author": {
    "name": "arkitectco",
    "url": "https://github.com/arkitectco"
  },
  "homepage": "https://github.com/arkitectco/SkillBotox",
  "repository": "https://github.com/arkitectco/SkillBotox",
  "license": "MIT",
  "keywords": [
    "skills",
    "governance",
    "audit",
    "evolution",
    "meta"
  ],
  "skills": "../packages/skill-pack/"
}
```

- [ ] **Step 2: Create `.claude-plugin/marketplace.json`**

```json
{
  "name": "skill-steroids-dev",
  "description": "SkillSteroids — governed skill library evolution",
  "owner": {
    "name": "arkitectco",
    "url": "https://github.com/arkitectco"
  },
  "plugins": [
    {
      "name": "skill-steroids",
      "description": "Governed audit and mutation for your AI agent skill library",
      "version": "2.2.0",
      "source": "./",
      "author": {
        "name": "arkitectco",
        "url": "https://github.com/arkitectco"
      }
    }
  ]
}
```

- [ ] **Step 3: Verify paths**

```bash
test -f .claude-plugin/../packages/skill-pack/SKILL.md
echo "Claude manifest paths: OK"
```

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "feat: add Claude plugin and marketplace manifests"
```

---

### Task 4: Codex plugin manifest

**Files:**
- Create: `.codex-plugin/plugin.json`

**Interfaces:**
- Produces: Codex registry manifest with interface block for Codex App discovery

- [ ] **Step 1: Create `.codex-plugin/plugin.json`**

```json
{
  "name": "skill-steroids",
  "version": "2.2.0",
  "description": "Meta-framework for deliberate evolution of your AI agent skill library — audit, govern, and mutate skills systematically.",
  "author": {
    "name": "arkitectco",
    "url": "https://github.com/arkitectco"
  },
  "homepage": "https://github.com/arkitectco/SkillBotox",
  "repository": "https://github.com/arkitectco/SkillBotox",
  "license": "MIT",
  "keywords": [
    "skills",
    "governance",
    "audit",
    "evolution",
    "meta",
    "agent"
  ],
  "skills": "../packages/skill-pack/",
  "interface": {
    "displayName": "SkillSteroids",
    "shortDescription": "Governed audit and mutation for agent skill libraries",
    "longDescription": "Run skill steroids audit for library health reports, or skill steroids mutate for one governed change. Includes Governor, Orchestrator, Evolver, and lineage tracking.",
    "developerName": "arkitectco",
    "category": "Coding",
    "capabilities": ["Interactive", "Read", "Write"],
    "defaultPrompt": [
      "run skill steroids audit",
      "skill steroids audit my skills library",
      "skill steroids mutate"
    ],
    "websiteURL": "https://github.com/arkitectco/SkillBotox"
  }
}
```

- [ ] **Step 2: Run version check**

```bash
./scripts/bump-plugin-version.sh --check
```

Expected: all five declared files show `2.2.0`, no MISSING.

- [ ] **Step 3: Commit**

```bash
git add .codex-plugin/plugin.json
git commit -m "feat: add Codex plugin manifest with interface block"
```

---

### Task 5: Manifest verification script

**Files:**
- Create: `scripts/verify-plugin-manifests.sh`
- Modify: `.github/workflows/evals.yml`

**Interfaces:**
- Produces: exit 0 when all manifest skill paths resolve

- [ ] **Step 1: Create `scripts/verify-plugin-manifests.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

check_manifest() {
  local label="$1"
  local manifest="$2"
  local skills_rel
  skills_rel="$(jq -r '.skills' "$manifest")"
  local skills_dir
  skills_dir="$(cd "$(dirname "$manifest")" && cd "$skills_rel" && pwd)"
  if [[ -f "$skills_dir/SKILL.md" && -f "$skills_dir/scripts/govern-check.sh" ]]; then
    echo "✓ $label → $skills_dir"
  else
    echo "✗ $label: pack not found at $skills_dir"
    FAIL=1
  fi
}

check_manifest "Cursor" "$ROOT/.cursor-plugin/plugin.json"
check_manifest "Claude" "$ROOT/.claude-plugin/plugin.json"
check_manifest "Codex" "$ROOT/.codex-plugin/plugin.json"

./scripts/bump-plugin-version.sh --check || FAIL=1

if [[ "$FAIL" -eq 0 ]]; then
  echo "Plugin manifests: PASS"
else
  echo "Plugin manifests: FAIL"
  exit 1
fi
```

```bash
chmod +x scripts/verify-plugin-manifests.sh
```

- [ ] **Step 2: Add CI step to `.github/workflows/evals.yml`**

After the doctor step in the `evals` job, add:

```yaml
      - name: Verify plugin manifests
        run: ./scripts/verify-plugin-manifests.sh
```

- [ ] **Step 3: Run locally**

```bash
./scripts/verify-plugin-manifests.sh
```

Expected: `Plugin manifests: PASS`

- [ ] **Step 4: Commit**

```bash
git add scripts/verify-plugin-manifests.sh .github/workflows/evals.yml
git commit -m "ci: verify plugin manifests resolve to skill pack"
```

---

### Task 6: Codex sync script

**Files:**
- Create: `scripts/sync-to-codex-plugin.sh`

**Interfaces:**
- Consumes: `packages/skill-pack/`, `.codex-plugin/plugin.json`
- Produces: PR on Codex registry fork at `plugins/skill-steroids/`

- [ ] **Step 1: Create `scripts/sync-to-codex-plugin.sh`**

Create `scripts/sync-to-codex-plugin.sh` with these constants at top:

```bash
FORK="${SKILL_STEROIDS_CODEX_FORK:-arkitectco/openai-codex-plugins}"
DEFAULT_BASE="main"
DEST_REL="plugins/skill-steroids"
```

Core behavior (adapt from Superpowers `sync-to-codex-plugin.sh`):

1. Preflight: require `rsync`, `git`, `gh`, `jq`, `python3`; read version from `.codex-plugin/plugin.json`
2. Flags: `-n` dry-run, `-y` skip confirm, `--bootstrap` create dest dir, `--local PATH` use existing fork checkout
3. Build `SYNC_SOURCE` temp dir containing:
   - Rsync `packages/skill-pack/` → `$SYNC_SOURCE/` (pack files at plugin root: `SKILL.md`, `orchestrator/`, `scripts/`, …)
   - Copy `.codex-plugin/` → `$SYNC_SOURCE/.codex-plugin/`
   - Rewrite `.codex-plugin/plugin.json` `"skills"` field to `"./"` (pack is now at plugin root after sync)
4. Rsync `$SYNC_SOURCE/` → `$FORK/plugins/skill-steroids/` with `--delete`
5. Exclude nothing from sync source (source is already pack-only); do NOT rsync whole monorepo
6. Push branch `sync/skill-steroids-<sha>-<timestamp>`, open PR via `gh pr create`

Pack-only rsync source build:

```bash
prepare_sync_source() {
  SYNC_SOURCE="$(mktemp -d)"
  rsync -a "$UPSTREAM/packages/skill-pack/" "$SYNC_SOURCE/"
  mkdir -p "$SYNC_SOURCE/.codex-plugin"
  cp "$UPSTREAM/.codex-plugin/plugin.json" "$SYNC_SOURCE/.codex-plugin/"
  # After flattening, skills path is plugin root
  jq '.skills = "./"' "$SYNC_SOURCE/.codex-plugin/plugin.json" > "$SYNC_SOURCE/.codex-plugin/plugin.json.tmp"
  mv "$SYNC_SOURCE/.codex-plugin/plugin.json.tmp" "$SYNC_SOURCE/.codex-plugin/plugin.json"
}
```

- [ ] **Step 2: Dry-run (requires fork or skip if fork not ready)**

```bash
./scripts/sync-to-codex-plugin.sh -n
```

Expected: preview shows only pack files + `.codex-plugin/`; no `apps/web/`.

If fork does not exist yet, document in `docs/PUBLISHING.md` and verify dry-run logic with a temp dest:

```bash
mkdir -p /tmp/codex-fork-test/plugins/skill-steroids
SKILL_STEROIDS_CODEX_FORK=... # or use --local after cloning fork
```

- [ ] **Step 3: Commit**

```bash
git add scripts/sync-to-codex-plugin.sh
git commit -m "feat: add Codex registry sync script for skill pack"
```

---

### Task 7: install.sh Codex target + docs

**Files:**
- Modify: `install.sh`
- Modify: `INSTALL.md`, `README.md`, `CHANGELOG.md`
- Create: `docs/PUBLISHING.md`

**Interfaces:**
- Produces: `--with-codex` flag; plugin-first install docs; release checklist

- [ ] **Step 1: Add Codex install target to `install.sh`**

After `CLAUDE_TARGET` definition, add:

```bash
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CODEX_TARGET="$CODEX_HOME/skills/skill-steroids"
```

Add `--with-codex` flag parsing and:

```bash
if [[ "$WITH_CODEX" -eq 1 ]]; then
  link_dir "$CODEX_TARGET"
fi
```

Update `usage()` to document `--with-codex` and `SKILL_STEROIDS_AGENTS=1`.

Update uninstall to `unlink_dir "$CODEX_TARGET"`.

- [ ] **Step 2: Create `docs/PUBLISHING.md`**

Include:

1. Prerequisites (fork `openai-codex-plugins`, `gh auth login`, Cursor/Claude marketplace access)
2. Version bump: `./scripts/bump-plugin-version.sh 2.2.0`
3. Verify: `./scripts/verify-plugin-manifests.sh`, doctor, evals
4. Cursor marketplace update steps (link to Cursor plugin docs)
5. Claude: `claude plugin marketplace add ./.claude-plugin/marketplace.json` (or org equivalent)
6. Codex: `./scripts/sync-to-codex-plugin.sh -y`
7. Post-release: update CHANGELOG

- [ ] **Step 3: Update `INSTALL.md`**

Add **Plugin install (recommended)** section before symlink install:

```markdown
## Plugin install (recommended)

| Platform | Install |
|----------|---------|
| Cursor | Install **skill-steroids** from Cursor marketplace, or open this repo as a local plugin |
| Claude Code | `claude plugin install skill-steroids` (after adding marketplace — see docs/PUBLISHING.md) |
| Codex | Install from Codex plugin registry after publish, or `./install.sh --with-codex` |

## Symlink install (OSS fallback)
```

Add Codex row to Agent support table:

```markdown
| Codex | `$CODEX_HOME/skills/skill-steroids/` or `~/.agents/skills/skill-steroids/` | same triggers |
```

- [ ] **Step 4: Fix README plugin section**

Replace outdated block:

```markdown
## Plugin packaging

Install via Cursor, Claude, or Codex plugin marketplaces (see [PUBLISHING.md](docs/PUBLISHING.md)), or use `./install.sh` for symlink install.

Manifests: `.cursor-plugin/`, `.claude-plugin/`, `.codex-plugin/` — all point at `packages/skill-pack/`.
```

Fix manual symlink example:

```bash
ln -sfn "$(pwd)/packages/skill-pack" ~/.cursor/skills/skill-steroids
```

- [ ] **Step 5: Prepend CHANGELOG**

```markdown
## [2.2.0] - 2026-06-24

### Added
- Multi-platform plugin manifests (Cursor, Claude, Codex) pointing at `packages/skill-pack/`
- `scripts/bump-plugin-version.sh`, `scripts/sync-to-codex-plugin.sh`, `scripts/verify-plugin-manifests.sh`
- `docs/PUBLISHING.md` release checklist

### Changed
- Plugin-first install docs; `install.sh` adds `--with-codex` for `$CODEX_HOME/skills/`
```

- [ ] **Step 6: Run install smoke test**

```bash
./install.sh --with-codex
readlink ~/.codex/skills/skill-steroids 2>/dev/null || readlink "${CODEX_HOME:-$HOME/.codex}/skills/skill-steroids"
```

Expected: symlink → `packages/skill-pack`

- [ ] **Step 7: Commit**

```bash
git add install.sh INSTALL.md README.md CHANGELOG.md docs/PUBLISHING.md
git commit -m "docs: plugin-first install and publishing checklist"
```

---

### Task 8: Final verification

**Files:**
- Modify: `docs/superpowers/specs/2026-06-24-skill-steroids-plugin-distribution-design.md` (checklist only if needed)

**Interfaces:**
- Consumes: all prior tasks

- [ ] **Step 1: Full verification suite**

```bash
./scripts/verify-plugin-manifests.sh
CI=true ./packages/skill-pack/scripts/doctor.sh
./evals/run-eval.sh
./install.sh
SKILL_STEROIDS_AGENTS=1 ./install.sh --with-claude --with-codex
```

Expected: all PASS

- [ ] **Step 2: Confirm sync dry-run excludes monorepo**

```bash
./scripts/sync-to-codex-plugin.sh -n 2>&1 | grep -E 'apps/web|evals/' && echo FAIL || echo "Sync source clean"
```

Expected: `Sync source clean` (no monorepo paths in preview)

- [ ] **Step 3: Commit any spec checklist updates**

```bash
git add docs/superpowers/specs/2026-06-24-skill-steroids-plugin-distribution-design.md
git commit -m "docs: mark plugin distribution spec implementation complete"
```

---

## Self-Review Checklist

| Spec requirement | Task |
|------------------|------|
| Thin manifests → pack | Tasks 2–4 |
| Version sync | Task 1 |
| Codex sync (Superpowers model) | Task 6 |
| All three marketplaces documented | Task 7 |
| install.sh fallback + Codex | Task 7 |
| No hooks | Global constraints |
| CI verification | Task 5 |
| No web/evals in plugin artifact | Task 6 dry-run |

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-06-24-skill-steroids-plugin-distribution.md`. Two execution options:

**1. Subagent-Driven (recommended)** — fresh subagent per task, spec + quality review between tasks

**2. Inline Execution** — execute in this session using executing-plans, batch with checkpoints

Which approach?
