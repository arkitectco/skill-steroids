# SkillSteroids Phase 0 + Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebrand Skill Botox → SkillSteroids and ship Phase 1 MicroSaaS MVP — Caveman-style marketing landing + anonymous single-skill zip audit + downloadable MD report (no auth, no Stripe, no mutation).

**Architecture:** npm workspaces monorepo with `apps/web` (Next.js 15 App Router on Vercel). Audit engine v1 shells existing `scripts/govern-check.sh` and `scripts/govern-semantic-check.sh` against extracted zip contents. Anonymous run reports persist client-side in `sessionStorage` for Phase 1 (Neon DB deferred to Phase 2).

**Tech Stack:** Next.js 15, React 19, TypeScript, Vitest, adm-zip, npm workspaces, Vercel

---

## File Map

| Path | Responsibility |
|------|----------------|
| `package.json` | Monorepo root workspaces |
| `apps/web/package.json` | Next.js app deps |
| `apps/web/next.config.ts` | Monorepo root path for scripts |
| `apps/web/app/globals.css` | Design tokens (Caveman-inspired) |
| `apps/web/app/layout.tsx` | Fonts + metadata |
| `apps/web/app/(marketing)/page.tsx` | Landing page |
| `apps/web/app/(marketing)/pricing/page.tsx` | Free vs Pro (Early access) |
| `apps/web/app/studio/page.tsx` | Upload dropzone |
| `apps/web/app/studio/runs/[id]/page.tsx` | Audit report |
| `apps/web/app/api/audit/route.ts` | POST zip → audit JSON |
| `apps/web/lib/audit/types.ts` | AuditReport types |
| `apps/web/lib/audit/parse-govern.ts` | Parse PASS/FAIL lines |
| `apps/web/lib/audit/run-audit.ts` | Extract zip + invoke bash |
| `apps/web/lib/audit/zip.ts` | Validate + safe extract |
| `apps/web/lib/audit/report-md.ts` | Export report as markdown |
| `apps/web/components/*.tsx` | UI primitives |
| `apps/web/__tests__/*.test.ts` | Vitest unit + integration |
| `apps/web/vitest.config.ts` | Test config |
| `apps/web/vercel.json` | maxDuration for audit route |

**Delete:** `site/index.html`

**Modify (rebrand):** `SKILL.md`, `install.sh`, `scripts/doctor.sh`, `README.md`, `CHANGELOG.md`, `.cursor-plugin/plugin.json`, all `*/SKILL.md` frontmatter names/triggers, `docs/*` references

**Manual (document only):** GitHub repo rename SkillBotox → SkillSteroids on github.com

---

### Task 1: Phase 0 cleanup and rebrand strings

**Files:**
- Delete: `site/index.html`
- Modify: `SKILL.md`, `install.sh`, `README.md`, `CHANGELOG.md`, `.cursor-plugin/plugin.json`, `scripts/doctor.sh`

- [ ] **Step 1: Delete premature static site**

```bash
rm -f site/index.html
rmdir site 2>/dev/null || true
```

- [ ] **Step 2: Update root SKILL.md frontmatter**

Replace frontmatter in `SKILL.md`:

```yaml
---
name: skill-steroids
description: Meta-framework for deliberate evolution of an AI agent skill library. Orchestrates observation, analysis, governance, and governed mutation. Use when the user says "run skill steroids", "skill steroids audit", "skill steroids mutate", "evolve my skills", "skill library health", "skill debt", "review my skills", or asks to improve their skill collection systematically.
disable-model-invocation: true
version: 2.0.0
---
```

Replace title `# Skill Botox Framework` with `# SkillSteroids Framework`.

Replace activation table triggers: `skill botox` → `skill steroids` throughout.

- [ ] **Step 3: Update install.sh targets**

In `install.sh`, replace:

```bash
CURSOR_TARGET="${SKILL_BOTOX_CURSOR:-$HOME/.cursor/skills/skill-botox}"
AGENTS_TARGET="$HOME/.agents/skills/skill-botox"
CLAUDE_TARGET="$HOME/.claude/skills/skill-botox"
SOURCE="${SKILL_BOTOX_HOME:-$REPO_ROOT}"
```

With:

```bash
CURSOR_TARGET="${SKILL_STEROIDS_CURSOR:-$HOME/.cursor/skills/skill-steroids}"
AGENTS_TARGET="$HOME/.agents/skills/skill-steroids"
CLAUDE_TARGET="$HOME/.claude/skills/skill-steroids"
SOURCE="${SKILL_STEROIDS_HOME:-$REPO_ROOT}"
```

Update usage text: `Skill Botox` → `SkillSteroids`, `SKILL_BOTOX_AGENTS` → `SKILL_STEROIDS_AGENTS`.

- [ ] **Step 4: Update doctor.sh install check**

In `scripts/doctor.sh`, replace:

```bash
elif [[ -L "$HOME/.cursor/skills/skill-botox" ]] || [[ -d "$HOME/.cursor/skills/skill-botox" ]]; then
  echo "✓ Cursor install: ~/.cursor/skills/skill-botox"
else
  echo "✗ Cursor install: not found (run ./install.sh)"
```

With:

```bash
elif [[ -L "$HOME/.cursor/skills/skill-steroids" ]] || [[ -d "$HOME/.cursor/skills/skill-steroids" ]]; then
  echo "✓ Cursor install: ~/.cursor/skills/skill-steroids"
else
  echo "✗ Cursor install: not found (run ./install.sh)"
```

- [ ] **Step 5: Update plugin.json**

```json
{
  "name": "skill-steroids",
  "version": "2.0.0",
  "description": "Meta-framework and MicroSaaS for deliberate evolution of your AI agent skill library.",
  "author": { "name": "arkitectco" },
  "keywords": ["skills", "meta", "evolution", "governance", "saas"]
}
```

- [ ] **Step 6: Update README title and install symlink example**

Replace `# Skill Botox Evolution Framework` with `# SkillSteroids`.

Replace symlink line:

```bash
ln -sf "$(pwd)" ~/.cursor/skills/skill-steroids
```

Add after Current Status:

```markdown
## Web app (MicroSaaS)

```bash
cd apps/web && npm run dev
```

Open http://localhost:3000 — landing + free skill audit studio.
```

- [ ] **Step 7: Prepend CHANGELOG 2.0.0 rebrand entry**

```markdown
## [2.0.0] - 2026-06-16

### Added
- SkillSteroids MicroSaaS Phase 1: `apps/web` landing + free audit studio

### Changed
- Rebrand Skill Botox → SkillSteroids
- Install path: `~/.cursor/skills/skill-steroids`
- Agent triggers: `skill steroids audit` / `skill steroids mutate`
```

- [ ] **Step 8: Bulk-replace remaining user-facing strings**

Run from repo root:

```bash
rg -l 'skill botox|Skill Botox|skill-botox' --glob '!node_modules' --glob '!.git' --glob '!docs/superpowers/**' | while read f; do
  sed -i '' \
    -e 's/skill-botox/skill-steroids/g' \
    -e 's/Skill Botox/SkillSteroids/g' \
    -e 's/skill botox/skill steroids/g' \
    "$f"
done
```

Review diff manually — restore historical plan filenames in `docs/superpowers/plans/` if needed.

- [ ] **Step 9: Verify OSS CI still passes**

```bash
./scripts/doctor.sh
./evals/run-eval.sh
```

Expected: both PASS.

- [ ] **Step 10: Commit**

```bash
git add -A
git commit -m "chore: rebrand Skill Botox to SkillSteroids (Phase 0)"
```

---

### Task 2: Monorepo root scaffold

**Files:**
- Create: `package.json`
- Create: `.gitignore` (append node entries if missing)

- [ ] **Step 1: Create root package.json**

Create `package.json`:

```json
{
  "name": "skillsteroids",
  "private": true,
  "version": "2.0.0",
  "workspaces": ["apps/*"],
  "scripts": {
    "dev": "npm run dev --workspace=@skillsteroids/web",
    "build": "npm run build --workspace=@skillsteroids/web",
    "test:web": "npm run test --workspace=@skillsteroids/web",
    "evals": "./evals/run-eval.sh"
  }
}
```

- [ ] **Step 2: Ensure .gitignore includes**

Append to `.gitignore` if not present:

```
node_modules/
apps/web/.next/
apps/web/out/
.env
.env.local
apps/web/.env.local
```

- [ ] **Step 3: Commit**

```bash
git add package.json .gitignore
git commit -m "chore: add npm workspaces monorepo root"
```

---

### Task 3: Scaffold Next.js app

**Files:**
- Create: `apps/web/package.json`, `apps/web/tsconfig.json`, `apps/web/next.config.ts`, `apps/web/next-env.d.ts`

- [ ] **Step 1: Create apps/web/package.json**

```json
{
  "name": "@skillsteroids/web",
  "version": "2.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev --port 3000",
    "build": "next build",
    "start": "next start",
    "test": "vitest run",
    "test:watch": "vitest"
  },
  "dependencies": {
    "adm-zip": "^0.5.16",
    "next": "^15.3.3",
    "react": "^19.1.0",
    "react-dom": "^19.1.0"
  },
  "devDependencies": {
    "@types/adm-zip": "^0.5.7",
    "@types/node": "^22.15.21",
    "@types/react": "^19.1.4",
    "typescript": "^5.8.3",
    "vitest": "^3.1.4"
  }
}
```

- [ ] **Step 2: Create tsconfig.json**

Create `apps/web/tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": false,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

- [ ] **Step 3: Create next.config.ts**

Create `apps/web/next.config.ts`:

```typescript
import type { NextConfig } from "next";
import path from "path";

const repoRoot = path.join(__dirname, "../..");

const nextConfig: NextConfig = {
  experimental: {
    serverActions: { bodySizeLimit: "512kb" },
  },
  env: {
    SKILLSTEROIDS_REPO_ROOT: repoRoot,
  },
};

export default nextConfig;
```

- [ ] **Step 4: Install dependencies**

```bash
npm install
```

Expected: `node_modules` at root; no errors.

- [ ] **Step 5: Commit**

```bash
git add apps/web/package.json apps/web/tsconfig.json apps/web/next.config.ts
git commit -m "feat: scaffold apps/web Next.js workspace"
```

---

### Task 4: Design system and layout

**Files:**
- Create: `apps/web/app/globals.css`
- Create: `apps/web/app/layout.tsx`

- [ ] **Step 1: Create globals.css**

Create `apps/web/app/globals.css`:

```css
:root {
  --bg: #0a0a0b;
  --bg-elevated: #111113;
  --border: #27272a;
  --text: #fafafa;
  --text-muted: #a1a1aa;
  --accent: #f59e0b;
  --accent-dim: #b45309;
  --pass: #22c55e;
  --warn: #f59e0b;
  --block: #ef4444;
  --font-display: "Instrument Serif", Georgia, serif;
  --font-body: "DM Sans", system-ui, sans-serif;
  --font-mono: "JetBrains Mono", ui-monospace, monospace;
}

* { box-sizing: border-box; margin: 0; padding: 0; }

html { scroll-behavior: smooth; }

body {
  background: var(--bg);
  color: var(--text);
  font-family: var(--font-body);
  line-height: 1.6;
  min-height: 100dvh;
}

body::before {
  content: "";
  position: fixed;
  inset: 0;
  pointer-events: none;
  opacity: 0.04;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
  z-index: 9999;
}

a { color: var(--accent); text-decoration: none; }
a:hover { text-decoration: underline; }

.container { max-width: 72rem; margin: 0 auto; padding: 0 1.5rem; }

.section-label {
  font-family: var(--font-mono);
  font-size: 0.75rem;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--accent);
  margin-bottom: 0.75rem;
}

.section-title {
  font-family: var(--font-display);
  font-size: clamp(2rem, 4vw, 3rem);
  font-weight: 400;
  line-height: 1.1;
  text-wrap: balance;
  margin-bottom: 1rem;
}

.btn {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  border-radius: 0.5rem;
  font-weight: 600;
  font-size: 0.9375rem;
  border: 1px solid transparent;
  cursor: pointer;
  text-decoration: none;
}

.btn-primary {
  background: var(--accent);
  color: #0a0a0b;
}
.btn-primary:hover { background: #fbbf24; text-decoration: none; }

.btn-ghost {
  background: transparent;
  border-color: var(--border);
  color: var(--text);
}
.btn-ghost:hover { border-color: var(--accent); text-decoration: none; }

.badge {
  font-family: var(--font-mono);
  font-size: 0.6875rem;
  padding: 0.25rem 0.5rem;
  border-radius: 0.25rem;
  border: 1px solid var(--border);
  color: var(--text-muted);
}

.verdict-pass { color: var(--pass); }
.verdict-warn { color: var(--warn); }
.verdict-block { color: var(--block); }

.terminal {
  background: var(--bg-elevated);
  border: 1px solid var(--border);
  border-radius: 0.75rem;
  overflow: hidden;
  font-family: var(--font-mono);
  font-size: 0.8125rem;
}

.terminal-bar {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  padding: 0.625rem 1rem;
  border-bottom: 1px solid var(--border);
  color: var(--text-muted);
  font-size: 0.75rem;
}

.terminal-body {
  padding: 1rem 1.25rem;
  overflow-x: auto;
  line-height: 1.7;
  white-space: pre-wrap;
}
```

- [ ] **Step 2: Create layout.tsx**

Create `apps/web/app/layout.tsx`:

```tsx
import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "SkillSteroids — stack your agent skills",
  description:
    "Governed audit and evolution for AI agent skill libraries. Free structural checks. Pro mutation coming soon.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="" />
        <link
          href="https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,400;9..40,600;9..40,700&family=Instrument+Serif&family=JetBrains+Mono:wght@400;500&display=swap"
          rel="stylesheet"
        />
      </head>
      <body>{children}</body>
    </html>
  );
}
```

- [ ] **Step 3: Commit**

```bash
git add apps/web/app/globals.css apps/web/app/layout.tsx
git commit -m "feat: add SkillSteroids design tokens and layout"
```

---

### Task 5: Audit types and govern output parser

**Files:**
- Create: `apps/web/lib/audit/types.ts`
- Create: `apps/web/lib/audit/parse-govern.ts`
- Create: `apps/web/__tests__/parse-govern.test.ts`
- Create: `apps/web/vitest.config.ts`

- [ ] **Step 1: Write failing parser test**

Create `apps/web/vitest.config.ts`:

```typescript
import { defineConfig } from "vitest/config";
import path from "path";

export default defineConfig({
  test: { environment: "node" },
  resolve: { alias: { "@": path.resolve(__dirname, ".") } },
});
```

Create `apps/web/__tests__/parse-govern.test.ts`:

```typescript
import { describe, it, expect } from "vitest";
import { parseGovernOutput, aggregateVerdict } from "@/lib/audit/parse-govern";

describe("parseGovernOutput", () => {
  it("parses PASS and FAIL lines", () => {
    const out = `  PASS P-02
  FAIL P-03: SKILL.md has 520 lines (>500)
  PASS P-05`;
    const rules = parseGovernOutput(out);
    expect(rules).toEqual([
      { principle: "P-02", pass: true },
      { principle: "P-03", pass: false, message: "SKILL.md has 520 lines (>500)" },
      { principle: "P-05", pass: true },
    ]);
  });
});

describe("aggregateVerdict", () => {
  it("returns BLOCK when any rule fails", () => {
    expect(aggregateVerdict([{ principle: "P-02", pass: true }])).toBe("PASS");
    expect(
      aggregateVerdict([
        { principle: "P-02", pass: true },
        { principle: "P-03", pass: false, message: "bloated" },
      ])
    ).toBe("BLOCK");
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd apps/web && npm run test
```

Expected: FAIL — module not found.

- [ ] **Step 3: Implement types and parser**

Create `apps/web/lib/audit/types.ts`:

```typescript
export type Verdict = "PASS" | "WARN" | "BLOCK";

export interface RuleResult {
  principle: string;
  pass: boolean;
  message?: string;
}

export interface SkillAuditResult {
  skillPath: string;
  skillName: string;
  structural: RuleResult[];
  semantic: RuleResult[];
  verdict: Verdict;
  lineCount: number;
}

export interface AuditReport {
  runId: string;
  engineVersion: string;
  createdAt: string;
  skills: SkillAuditResult[];
  summary: {
    structuralHealthPct: number;
    passCount: number;
    blockCount: number;
    warnCount: number;
  };
}
```

Create `apps/web/lib/audit/parse-govern.ts`:

```typescript
import type { RuleResult, Verdict } from "./types";

const LINE_RE = /^\s+(PASS|FAIL)\s+(P-\d+)(?::\s*(.+))?$/;

export function parseGovernOutput(output: string): RuleResult[] {
  const results: RuleResult[] = [];
  for (const line of output.split("\n")) {
    const m = line.match(LINE_RE);
    if (!m) continue;
    results.push({
      principle: m[2],
      pass: m[1] === "PASS",
      message: m[3]?.trim(),
    });
  }
  return results;
}

export function aggregateVerdict(rules: RuleResult[]): Verdict {
  if (rules.some((r) => !r.pass)) return "BLOCK";
  return "PASS";
}

export function mergeRules(...groups: RuleResult[][]): RuleResult[] {
  const map = new Map<string, RuleResult>();
  for (const group of groups) {
    for (const r of group) map.set(r.principle, r);
  }
  return [...map.values()].sort((a, b) => a.principle.localeCompare(b.principle));
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd apps/web && npm run test
```

Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add apps/web/lib/audit apps/web/__tests__ apps/web/vitest.config.ts
git commit -m "feat: add govern output parser with tests"
```

---

### Task 6: Zip validation and safe extract

**Files:**
- Create: `apps/web/lib/audit/zip.ts`
- Create: `apps/web/__tests__/zip.test.ts`

- [ ] **Step 1: Write failing zip test**

Create `apps/web/__tests__/zip.test.ts`:

```typescript
import { describe, it, expect } from "vitest";
import AdmZip from "adm-zip";
import fs from "fs";
import os from "os";
import path from "path";
import { extractSkillZip, findSkillMdFiles } from "@/lib/audit/zip";

function makeZip(files: Record<string, string>): Buffer {
  const zip = new AdmZip();
  for (const [name, content] of Object.entries(files)) {
    zip.addFile(name, Buffer.from(content, "utf8"));
  }
  return zip.toBuffer();
}

describe("extractSkillZip", () => {
  it("rejects zip without SKILL.md", () => {
    const buf = makeZip({ "readme.txt": "hi" });
    expect(() => extractSkillZip(buf, { maxBytes: 500_000, maxSkills: 1 })).toThrow(
      /SKILL\.md/
    );
  });

  it("extracts single skill with SKILL.md", () => {
    const buf = makeZip({
      "my-skill/SKILL.md": "---\nname: test\n---\n# Test",
    });
    const dir = extractSkillZip(buf, { maxBytes: 500_000, maxSkills: 1 });
    expect(findSkillMdFiles(dir)).toHaveLength(1);
    fs.rmSync(dir, { recursive: true, force: true });
  });

  it("rejects path traversal entries", () => {
    const zip = new AdmZip();
    zip.addFile("../../../etc/passwd", Buffer.from("bad"));
    zip.addFile("skill/SKILL.md", Buffer.from("---\nname: x\n---\n"));
    expect(() =>
      extractSkillZip(zip.toBuffer(), { maxBytes: 500_000, maxSkills: 1 })
    ).toThrow(/traversal/);
  });
});
```

- [ ] **Step 2: Run test — expect FAIL**

```bash
cd apps/web && npm run test
```

- [ ] **Step 3: Implement zip.ts**

Create `apps/web/lib/audit/zip.ts`:

```typescript
import AdmZip from "adm-zip";
import fs from "fs";
import os from "os";
import path from "path";

export interface ZipOptions {
  maxBytes: number;
  maxSkills: number;
}

export function extractSkillZip(buffer: Buffer, opts: ZipOptions): string {
  if (buffer.length > opts.maxBytes) {
    throw new Error(`Zip exceeds ${opts.maxBytes} bytes`);
  }

  const zip = new AdmZip(buffer);
  const entries = zip.getEntries();
  if (entries.length > 500) throw new Error("Too many files in zip");

  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "skillsteroids-"));

  for (const entry of entries) {
    if (entry.isDirectory) continue;
    const normalized = path.normalize(entry.entryName);
    if (normalized.startsWith("..") || path.isAbsolute(normalized)) {
      fs.rmSync(tmp, { recursive: true, force: true });
      throw new Error("Zip contains path traversal entry");
    }
    const dest = path.join(tmp, normalized);
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.writeFileSync(dest, entry.getData());
  }

  const skills = findSkillMdFiles(tmp);
  if (skills.length === 0) {
    fs.rmSync(tmp, { recursive: true, force: true });
    throw new Error("No SKILL.md found in zip");
  }
  if (skills.length > opts.maxSkills) {
    fs.rmSync(tmp, { recursive: true, force: true });
    throw new Error(`Zip contains ${skills.length} skills; max ${opts.maxSkills}`);
  }

  return tmp;
}

export function findSkillMdFiles(root: string): string[] {
  const results: string[] = [];
  function walk(dir: string) {
    for (const name of fs.readdirSync(dir)) {
      const full = path.join(dir, name);
      const stat = fs.statSync(full);
      if (stat.isDirectory()) walk(full);
      else if (name === "SKILL.md") results.push(full);
    }
  }
  walk(root);
  return results;
}

export function cleanupExtractDir(dir: string) {
  fs.rmSync(dir, { recursive: true, force: true });
}
```

- [ ] **Step 4: Run tests — expect PASS**

```bash
cd apps/web && npm run test
```

- [ ] **Step 5: Commit**

```bash
git add apps/web/lib/audit/zip.ts apps/web/__tests__/zip.test.ts
git commit -m "feat: add safe zip extract for skill uploads"
```

---

### Task 7: Run audit via bash scripts

**Files:**
- Create: `apps/web/lib/audit/run-audit.ts`
- Create: `apps/web/lib/repo-root.ts`
- Create: `apps/web/__tests__/run-audit.integration.test.ts`

- [ ] **Step 1: Create repo-root helper**

Create `apps/web/lib/repo-root.ts`:

```typescript
import path from "path";

export function getRepoRoot(): string {
  const fromEnv = process.env.SKILLSTEROIDS_REPO_ROOT;
  if (fromEnv) return fromEnv;
  return path.join(process.cwd(), "../..");
}
```

- [ ] **Step 2: Write integration test**

Create `apps/web/__tests__/run-audit.integration.test.ts`:

```typescript
import { describe, it, expect } from "vitest";
import path from "path";
import { runAuditOnSkillFile } from "@/lib/audit/run-audit";
import { getRepoRoot } from "@/lib/repo-root";

const repo = getRepoRoot();

describe("runAuditOnSkillFile integration", () => {
  it("PASS on golden-pass minimal-skill", async () => {
    const skill = path.join(repo, "evals/golden-pass/minimal-skill/SKILL.md");
    const result = await runAuditOnSkillFile(skill);
    expect(result.verdict).toBe("PASS");
    expect(result.structural.every((r) => r.pass)).toBe(true);
  });

  it("BLOCK on short-desc violation", async () => {
    const skill = path.join(repo, "evals/golden-violations/short-desc/SKILL.md");
    const result = await runAuditOnSkillFile(skill);
    expect(result.verdict).toBe("BLOCK");
    expect(result.structural.find((r) => r.principle === "P-02")?.pass).toBe(false);
  });
});
```

- [ ] **Step 3: Run test — expect FAIL**

```bash
cd apps/web && npm run test
```

- [ ] **Step 4: Implement run-audit.ts**

Create `apps/web/lib/audit/run-audit.ts`:

```typescript
import { execFile } from "child_process";
import fs from "fs";
import path from "path";
import { promisify } from "util";
import { getRepoRoot } from "@/lib/repo-root";
import { aggregateVerdict, mergeRules, parseGovernOutput } from "./parse-govern";
import type { AuditReport, SkillAuditResult } from "./types";
import { cleanupExtractDir, extractSkillZip, findSkillMdFiles } from "./zip";

const execFileAsync = promisify(execFile);

async function runScript(script: string, args: string[]): Promise<string> {
  const repo = getRepoRoot();
  const scriptPath = path.join(repo, "scripts", script);
  const { stdout, stderr } = await execFileAsync("bash", [scriptPath, ...args], {
    cwd: repo,
    timeout: 30_000,
  });
  return `${stdout}\n${stderr}`;
}

function isOrchestratorSkill(filePath: string, content: string): boolean {
  return (
    filePath.includes("orchestrator") ||
    /orchestrator/i.test(content.slice(0, 500))
  );
}

function readSkillName(content: string): string {
  const m = content.match(/^name:\s*(.+)$/m);
  return m ? m[1].trim().replace(/^["']|["']$/g, "") : "unknown";
}

export async function runAuditOnSkillFile(skillPath: string): Promise<SkillAuditResult> {
  const content = fs.readFileSync(skillPath, "utf8");
  const orchFlag = isOrchestratorSkill(skillPath, content) ? ["--orchestrator"] : [];

  const structuralOut = await runScript("govern-check.sh", [skillPath, ...orchFlag]);
  const semanticOut = await runScript("govern-semantic-check.sh", [skillPath]);

  const structural = parseGovernOutput(structuralOut);
  const semantic = parseGovernOutput(semanticOut);
  const all = mergeRules(structural, semantic);

  return {
    skillPath,
    skillName: readSkillName(content),
    structural,
    semantic,
    verdict: aggregateVerdict(all),
    lineCount: content.split("\n").length,
  };
}

export async function runAuditFromZip(
  zipBuffer: Buffer,
  engineVersion: string
): Promise<AuditReport> {
  const extractDir = extractSkillZip(zipBuffer, { maxBytes: 500_000, maxSkills: 1 });
  try {
    const skillFiles = findSkillMdFiles(extractDir);
    const skills: SkillAuditResult[] = [];
    for (const file of skillFiles) {
      skills.push(await runAuditOnSkillFile(file));
    }
    const passCount = skills.filter((s) => s.verdict === "PASS").length;
    const blockCount = skills.filter((s) => s.verdict === "BLOCK").length;
    return {
      runId: crypto.randomUUID(),
      engineVersion,
      createdAt: new Date().toISOString(),
      skills,
      summary: {
        structuralHealthPct: skills.length
          ? Math.round((passCount / skills.length) * 100)
          : 0,
        passCount,
        blockCount,
        warnCount: 0,
      },
    };
  } finally {
    cleanupExtractDir(extractDir);
  }
}
```

- [ ] **Step 5: Run integration tests**

```bash
cd apps/web && npm run test
```

Expected: all tests PASS.

- [ ] **Step 6: Commit**

```bash
git add apps/web/lib/audit/run-audit.ts apps/web/lib/repo-root.ts apps/web/__tests__/run-audit.integration.test.ts
git commit -m "feat: wire audit engine to OSS govern scripts"
```

---

### Task 8: Report markdown export

**Files:**
- Create: `apps/web/lib/audit/report-md.ts`
- Create: `apps/web/__tests__/report-md.test.ts`

- [ ] **Step 1: Write test**

Create `apps/web/__tests__/report-md.test.ts`:

```typescript
import { describe, it, expect } from "vitest";
import { auditReportToMarkdown } from "@/lib/audit/report-md";
import type { AuditReport } from "@/lib/audit/types";

const sample: AuditReport = {
  runId: "test-run",
  engineVersion: "abc123",
  createdAt: "2026-06-16T00:00:00.000Z",
  skills: [
    {
      skillPath: "/tmp/s/SKILL.md",
      skillName: "demo",
      structural: [{ principle: "P-02", pass: true }],
      semantic: [{ principle: "P-01", pass: true }],
      verdict: "PASS",
      lineCount: 42,
    },
  ],
  summary: { structuralHealthPct: 100, passCount: 1, blockCount: 0, warnCount: 0 },
};

describe("auditReportToMarkdown", () => {
  it("includes run id and verdict", () => {
    const md = auditReportToMarkdown(sample);
    expect(md).toContain("test-run");
    expect(md).toContain("PASS");
    expect(md).toContain("demo");
  });
});
```

- [ ] **Step 2: Implement report-md.ts**

Create `apps/web/lib/audit/report-md.ts`:

```typescript
import type { AuditReport, SkillAuditResult } from "./types";

function skillSection(s: SkillAuditResult): string {
  const rules = [...s.structural, ...s.semantic];
  const rows = rules
    .map(
      (r) =>
        `| ${r.principle} | ${r.pass ? "PASS" : "BLOCK"} | ${r.message ?? ""} |`
    )
    .join("\n");
  return `### ${s.skillName}

**Verdict:** ${s.verdict} · **Lines:** ${s.lineCount}

| Principle | Result | Detail |
|-----------|--------|--------|
${rows}
`;
}

export function auditReportToMarkdown(report: AuditReport): string {
  return `# SkillSteroids Audit Report

**Run ID:** ${report.runId}
**Engine:** ${report.engineVersion}
**Date:** ${report.createdAt}

## Summary

- Structural health: ${report.summary.structuralHealthPct}%
- PASS: ${report.summary.passCount} · BLOCK: ${report.summary.blockCount}

## Skills

${report.skills.map(skillSection).join("\n")}

---
*Generated by SkillSteroids — https://skillsteroids.dev*
`;
}
```

- [ ] **Step 3: Run tests and commit**

```bash
cd apps/web && npm run test
git add apps/web/lib/audit/report-md.ts apps/web/__tests__/report-md.test.ts
git commit -m "feat: add audit report markdown export"
```

---

### Task 9: API route POST /api/audit

**Files:**
- Create: `apps/web/app/api/audit/route.ts`
- Create: `apps/web/lib/rate-limit.ts`
- Create: `apps/web/vercel.json`

- [ ] **Step 1: Create simple rate limiter**

Create `apps/web/lib/rate-limit.ts`:

```typescript
const hits = new Map<string, { count: number; reset: number }>();

export function rateLimit(ip: string, limit = 10, windowMs = 3_600_000): boolean {
  const now = Date.now();
  const entry = hits.get(ip);
  if (!entry || now > entry.reset) {
    hits.set(ip, { count: 1, reset: now + windowMs });
    return true;
  }
  if (entry.count >= limit) return false;
  entry.count += 1;
  return true;
}
```

- [ ] **Step 2: Create API route**

Create `apps/web/app/api/audit/route.ts`:

```typescript
import { NextRequest, NextResponse } from "next/server";
import { runAuditFromZip } from "@/lib/audit/run-audit";
import { rateLimit } from "@/lib/rate-limit";

export const runtime = "nodejs";
export const maxDuration = 60;

function engineVersion(): string {
  return process.env.VERCEL_GIT_COMMIT_SHA ?? "dev";
}

export async function POST(req: NextRequest) {
  const ip = req.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ?? "unknown";
  if (!rateLimit(ip)) {
    return NextResponse.json({ error: "Rate limit exceeded. Try again later." }, { status: 429 });
  }

  const form = await req.formData();
  const file = form.get("file");
  if (!(file instanceof File)) {
    return NextResponse.json({ error: "Missing file field" }, { status: 400 });
  }

  const buffer = Buffer.from(await file.arrayBuffer());
  if (buffer.length === 0) {
    return NextResponse.json({ error: "Empty file" }, { status: 400 });
  }

  try {
    const report = await runAuditFromZip(buffer, engineVersion());
    return NextResponse.json(report);
  } catch (e) {
    const message = e instanceof Error ? e.message : "Audit failed";
    return NextResponse.json({ error: message }, { status: 400 });
  }
}
```

- [ ] **Step 3: Create vercel.json**

Create `apps/web/vercel.json`:

```json
{
  "buildCommand": "npm run build",
  "installCommand": "npm install",
  "framework": "nextjs",
  "functions": {
    "app/api/audit/route.ts": { "maxDuration": 60 }
  }
}
```

- [ ] **Step 4: Manual smoke test**

```bash
cd apps/web && npm run dev
```

In another terminal, build a test zip from golden fixture:

```bash
cd evals/golden-pass/minimal-skill && zip -r /tmp/test-skill.zip . && cd -
curl -s -X POST -F "file=@/tmp/test-skill.zip" http://localhost:3000/api/audit | head -c 500
```

Expected: JSON with `"verdict":"PASS"` or structural PASS rules.

- [ ] **Step 5: Commit**

```bash
git add apps/web/app/api/audit/route.ts apps/web/lib/rate-limit.ts apps/web/vercel.json
git commit -m "feat: add POST /api/audit with rate limiting"
```

---

### Task 10: UI components

**Files:**
- Create: `apps/web/components/SiteHeader.tsx`
- Create: `apps/web/components/SectionLabel.tsx`
- Create: `apps/web/components/TerminalBlock.tsx`
- Create: `apps/web/components/VerdictBadge.tsx`
- Create: `apps/web/components/SkillDropzone.tsx`

- [ ] **Step 1: Create components**

Create `apps/web/components/SiteHeader.tsx`:

```tsx
import Link from "next/link";

export function SiteHeader() {
  return (
    <header style={{ borderBottom: "1px solid var(--border)", padding: "1rem 0" }}>
      <div className="container" style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <Link href="/" style={{ fontFamily: "var(--font-display)", fontSize: "1.25rem", color: "var(--text)" }}>
          SkillSteroids
        </Link>
        <nav style={{ display: "flex", gap: "1.25rem", alignItems: "center", fontSize: "0.875rem" }}>
          <Link href="/#ecosystem">Ecosystem</Link>
          <Link href="/pricing">Pricing</Link>
          <Link href="/studio">Studio</Link>
          <a href="https://github.com/arkitectco/SkillSteroids" target="_blank" rel="noopener">GitHub ↗</a>
        </nav>
      </div>
    </header>
  );
}
```

Create `apps/web/components/SectionLabel.tsx`:

```tsx
export function SectionLabel({ children }: { children: React.ReactNode }) {
  return <p className="section-label">{children}</p>;
}
```

Create `apps/web/components/TerminalBlock.tsx`:

```tsx
export function TerminalBlock({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="terminal">
      <div className="terminal-bar">{title}</div>
      <pre className="terminal-body">{children}</pre>
    </div>
  );
}
```

Create `apps/web/components/VerdictBadge.tsx`:

```tsx
import type { Verdict } from "@/lib/audit/types";

const cls: Record<Verdict, string> = {
  PASS: "verdict-pass",
  WARN: "verdict-warn",
  BLOCK: "verdict-block",
};

export function VerdictBadge({ verdict }: { verdict: Verdict }) {
  return <span className={cls[verdict]} style={{ fontFamily: "var(--font-mono)", fontWeight: 600 }}>{verdict}</span>;
}
```

Create `apps/web/components/SkillDropzone.tsx`:

```tsx
"use client";

import { useCallback, useState } from "react";
import { useRouter } from "next/navigation";
import type { AuditReport } from "@/lib/audit/types";

const STORAGE_PREFIX = "skillsteroids:run:";

export function saveReport(report: AuditReport) {
  sessionStorage.setItem(`${STORAGE_PREFIX}${report.runId}`, JSON.stringify(report));
}

export function loadReport(runId: string): AuditReport | null {
  const raw = sessionStorage.getItem(`${STORAGE_PREFIX}${runId}`);
  return raw ? (JSON.parse(raw) as AuditReport) : null;
}

export function SkillDropzone() {
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const upload = useCallback(async (file: File) => {
    setError(null);
    setLoading(true);
    try {
      const form = new FormData();
      form.append("file", file);
      const res = await fetch("/api/audit", { method: "POST", body: form });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error ?? "Upload failed");
      saveReport(data as AuditReport);
      router.push(`/studio/runs/${data.runId}`);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Upload failed");
    } finally {
      setLoading(false);
    }
  }, [router]);

  return (
    <div
      onDragOver={(e) => e.preventDefault()}
      onDrop={(e) => {
        e.preventDefault();
        const f = e.dataTransfer.files[0];
        if (f) upload(f);
      }}
      style={{
        border: "2px dashed var(--border)",
        borderRadius: "0.75rem",
        padding: "3rem 2rem",
        textAlign: "center",
        background: "var(--bg-elevated)",
      }}
    >
      <p style={{ marginBottom: "1rem", color: "var(--text-muted)" }}>
        Drop your skill folder (.zip) — must include SKILL.md
      </p>
      <label className="btn btn-primary" style={{ cursor: "pointer" }}>
        {loading ? "Auditing…" : "Choose zip file"}
        <input
          type="file"
          accept=".zip,application/zip"
          hidden
          disabled={loading}
          onChange={(e) => {
            const f = e.target.files?.[0];
            if (f) upload(f);
          }}
        />
      </label>
      {error && <p style={{ color: "var(--block)", marginTop: "1rem", fontSize: "0.875rem" }}>{error}</p>}
    </div>
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add apps/web/components
git commit -m "feat: add SkillSteroids UI components"
```

---

### Task 11: Marketing landing page

**Files:**
- Create: `apps/web/app/(marketing)/page.tsx`
- Create: `apps/web/app/(marketing)/pricing/page.tsx`

- [ ] **Step 1: Create landing page**

Create `apps/web/app/(marketing)/page.tsx`:

```tsx
import Link from "next/link";
import { SiteHeader } from "@/components/SiteHeader";
import { SectionLabel } from "@/components/SectionLabel";
import { TerminalBlock } from "@/components/TerminalBlock";

export default function HomePage() {
  return (
    <>
      <SiteHeader />
      <main>
        <section className="container" style={{ padding: "5rem 1.5rem 4rem" }}>
          <div style={{ display: "flex", gap: "0.5rem", marginBottom: "1.5rem", flexWrap: "wrap" }}>
            <span className="badge">v2.0 · audit free</span>
            <span className="badge">MIT · markdown-first</span>
          </div>
          <h1 className="section-title" style={{ fontSize: "clamp(2.5rem, 5vw, 4.5rem)", maxWidth: "48rem" }}>
            Stack your agent skills.
          </h1>
          <p style={{ fontFamily: "var(--font-mono)", color: "var(--accent)", marginBottom: "1rem" }}>
            [thesis] why skill debt when skill can compound.
          </p>
          <p style={{ color: "var(--text-muted)", maxWidth: "38rem", marginBottom: "2rem", fontSize: "1.0625rem" }}>
            SkillSteroids audits, governs, and evolves your AI skill library — deterministic checks free,
            governed mutation on Pro.
          </p>
          <div style={{ display: "flex", gap: "1rem", flexWrap: "wrap" }}>
            <Link href="/studio" className="btn btn-primary">Audit a skill</Link>
            <Link href="/pricing" className="btn btn-ghost">View pricing →</Link>
          </div>
        </section>

        <section id="ecosystem" className="container" style={{ padding: "4rem 1.5rem" }}>
          <SectionLabel>§ 01 · Ecosystem</SectionLabel>
          <h2 className="section-title">Six skills. One audit pipeline.</h2>
          <p style={{ color: "var(--text-muted)", maxWidth: "40rem", marginBottom: "2rem" }}>
            Observer → Analyzer → Governor → Evolver → Orchestrator → Lineage. Composable OSS modules;
            the studio runs the same govern engine as CI.
          </p>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(16rem, 1fr))", gap: "1rem" }}>
            {["Observer", "Analyzer", "Governor", "Evolver", "Orchestrator", "Lineage"].map((name) => (
              <div key={name} style={{ border: "1px solid var(--border)", borderRadius: "0.5rem", padding: "1.25rem", background: "var(--bg-elevated)" }}>
                <strong>{name}</strong>
              </div>
            ))}
          </div>
        </section>

        <section className="container" style={{ padding: "4rem 1.5rem" }}>
          <SectionLabel>§ 02 · Studio</SectionLabel>
          <h2 className="section-title">Upload. Verdict. Download.</h2>
          <TerminalBlock title="skillsteroids · audit">
{`$ skill steroids audit
▸ extract zip          ✓ SKILL.md found
▸ govern-check.sh        PASS P-02 · PASS P-03 · PASS P-05
▸ govern-semantic.sh     PASS P-01 · PASS P-04 · PASS P-06
→ verdict PASS · download report.md`}
          </TerminalBlock>
        </section>

        <section className="container" style={{ padding: "4rem 1.5rem 6rem" }}>
          <SectionLabel>§ 03 · Proof</SectionLabel>
          <h2 className="section-title">Same engine as OSS evals.</h2>
          <p style={{ color: "var(--text-muted)", marginBottom: "1.5rem" }}>
            Golden fixtures in CI. Web audits must match bash govern-check output.
          </p>
          <Link href="https://github.com/arkitectco/SkillSteroids" className="btn btn-ghost">View on GitHub ↗</Link>
        </section>
      </main>
    </>
  );
}
```

- [ ] **Step 2: Create pricing page**

Create `apps/web/app/(marketing)/pricing/page.tsx`:

```tsx
import Link from "next/link";
import { SiteHeader } from "@/components/SiteHeader";
import { SectionLabel } from "@/components/SectionLabel";

export default function PricingPage() {
  return (
    <>
      <SiteHeader />
      <main className="container" style={{ padding: "4rem 1.5rem" }}>
        <SectionLabel>§ Pricing</SectionLabel>
        <h1 className="section-title">Free audit. Pro gains.</h1>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(16rem, 1fr))", gap: "1.5rem", marginTop: "2rem" }}>
          <div style={{ border: "1px solid var(--border)", borderRadius: "0.75rem", padding: "1.5rem" }}>
            <h2 style={{ marginBottom: "0.5rem" }}>Free</h2>
            <p style={{ color: "var(--text-muted)", fontSize: "0.875rem", marginBottom: "1rem" }}>Deterministic audit</p>
            <ul style={{ color: "var(--text-muted)", fontSize: "0.875rem", paddingLeft: "1.25rem" }}>
              <li>Single-skill zip upload</li>
              <li>Structural + semantic checks</li>
              <li>MD report download</li>
            </ul>
            <Link href="/studio" className="btn btn-primary" style={{ marginTop: "1.5rem", display: "inline-flex" }}>Audit now</Link>
          </div>
          <div style={{ border: "1px solid var(--accent-dim)", borderRadius: "0.75rem", padding: "1.5rem" }}>
            <h2 style={{ marginBottom: "0.5rem" }}>Pro</h2>
            <p style={{ color: "var(--accent)", fontSize: "0.875rem", marginBottom: "1rem" }}>Early access — coming Phase 3</p>
            <ul style={{ color: "var(--text-muted)", fontSize: "0.875rem", paddingLeft: "1.25rem" }}>
              <li>AI mutation + diff export</li>
              <li>Saved runs</li>
              <li>Multi-skill library scan</li>
              <li>Mutation quota + BYOK</li>
            </ul>
          </div>
        </div>
      </main>
    </>
  );
}
```

- [ ] **Step 3: Commit**

```bash
git add apps/web/app/\(marketing\)
git commit -m "feat: add marketing landing and pricing pages"
```

---

### Task 12: Studio upload and report pages

**Files:**
- Create: `apps/web/app/studio/page.tsx`
- Create: `apps/web/app/studio/runs/[id]/page.tsx`
- Create: `apps/web/app/studio/runs/[id]/ReportClient.tsx`

- [ ] **Step 1: Studio upload page**

Create `apps/web/app/studio/page.tsx`:

```tsx
import { SiteHeader } from "@/components/SiteHeader";
import { SectionLabel } from "@/components/SectionLabel";
import { SkillDropzone } from "@/components/SkillDropzone";

export default function StudioPage() {
  return (
    <>
      <SiteHeader />
      <main className="container" style={{ padding: "4rem 1.5rem" }}>
        <SectionLabel>§ Studio</SectionLabel>
        <h1 className="section-title">Audit a skill</h1>
        <p style={{ color: "var(--text-muted)", marginBottom: "2rem" }}>
          Upload a zip of one skill folder. No account required.
        </p>
        <SkillDropzone />
      </main>
    </>
  );
}
```

- [ ] **Step 2: Report client component**

Create `apps/web/app/studio/runs/[id]/ReportClient.tsx`:

```tsx
"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { loadReport } from "@/components/SkillDropzone";
import { VerdictBadge } from "@/components/VerdictBadge";
import { auditReportToMarkdown } from "@/lib/audit/report-md";
import type { AuditReport } from "@/lib/audit/types";

export function ReportClient({ runId }: { runId: string }) {
  const [report, setReport] = useState<AuditReport | null>(null);

  useEffect(() => {
    setReport(loadReport(runId));
  }, [runId]);

  if (!report) {
    return (
      <p style={{ color: "var(--text-muted)" }}>
        Report not found in this session. <Link href="/studio">Run a new audit</Link>.
      </p>
    );
  }

  const skill = report.skills[0];

  function downloadMd() {
    const md = auditReportToMarkdown(report!);
    const blob = new Blob([md], { type: "text/markdown" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `skillsteroids-audit-${report!.runId}.md`;
    a.click();
    URL.revokeObjectURL(url);
  }

  return (
    <div>
      <p style={{ color: "var(--text-muted)", fontSize: "0.875rem", marginBottom: "1rem" }}>
        Run {report.runId} · Engine {report.engineVersion.slice(0, 7)}
      </p>
      {skill && (
        <>
          <p style={{ marginBottom: "1rem" }}>
            <strong>{skill.skillName}</strong> — <VerdictBadge verdict={skill.verdict} />
          </p>
          <table style={{ width: "100%", borderCollapse: "collapse", fontSize: "0.875rem", marginBottom: "2rem" }}>
            <thead>
              <tr style={{ borderBottom: "1px solid var(--border)", textAlign: "left" }}>
                <th style={{ padding: "0.5rem" }}>Principle</th>
                <th style={{ padding: "0.5rem" }}>Result</th>
                <th style={{ padding: "0.5rem" }}>Detail</th>
              </tr>
            </thead>
            <tbody>
              {[...skill.structural, ...skill.semantic].map((r) => (
                <tr key={r.principle} style={{ borderBottom: "1px solid var(--border)" }}>
                  <td style={{ padding: "0.5rem", fontFamily: "var(--font-mono)" }}>{r.principle}</td>
                  <td style={{ padding: "0.5rem" }}>{r.pass ? "PASS" : "BLOCK"}</td>
                  <td style={{ padding: "0.5rem", color: "var(--text-muted)" }}>{r.message ?? ""}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </>
      )}
      <div style={{ display: "flex", gap: "1rem", flexWrap: "wrap" }}>
        <button type="button" className="btn btn-primary" onClick={downloadMd}>Download report</button>
        <Link href="/studio" className="btn btn-ghost">Audit another</Link>
      </div>
      <p style={{ color: "var(--text-muted)", fontSize: "0.8125rem", marginTop: "2rem" }}>
        Save runs and AI mutation — Pro (Phase 3). Join early access from pricing.
      </p>
    </div>
  );
}
```

- [ ] **Step 3: Report page**

Create `apps/web/app/studio/runs/[id]/page.tsx`:

```tsx
import { SiteHeader } from "@/components/SiteHeader";
import { SectionLabel } from "@/components/SectionLabel";
import { ReportClient } from "./ReportClient";

export default async function RunReportPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  return (
    <>
      <SiteHeader />
      <main className="container" style={{ padding: "4rem 1.5rem" }}>
        <SectionLabel>§ Report</SectionLabel>
        <h1 className="section-title">Audit results</h1>
        <ReportClient runId={id} />
      </main>
    </>
  );
}
```

- [ ] **Step 4: Build and smoke test full flow**

```bash
cd apps/web && npm run build
npm run dev
```

Browser: http://localhost:3000 → Audit a skill → upload golden-pass zip → see PASS → download MD.

- [ ] **Step 5: Commit**

```bash
git add apps/web/app/studio
git commit -m "feat: add studio upload and audit report pages"
```

---

### Task 13: CI and root README wiring

**Files:**
- Modify: `.github/workflows/evals.yml`
- Modify: `README.md`

- [ ] **Step 1: Extend CI workflow**

Add job to `.github/workflows/evals.yml`:

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

- [ ] **Step 2: Final README MicroSaaS section** (if not done in Task 1)

Ensure README includes dev command and link to spec:

```markdown
Design spec: [docs/superpowers/specs/2026-06-16-skillsteroids-microsaas-design.md](docs/superpowers/specs/2026-06-16-skillsteroids-microsaas-design.md)
```

- [ ] **Step 3: Run full verification**

```bash
./evals/run-eval.sh
npm run test --workspace=@skillsteroids/web
cd apps/web && npm run build
```

Expected: all PASS.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/evals.yml README.md
git commit -m "ci: add web vitest job; document MicroSaaS dev flow"
```

---

## Self-Review

### Spec coverage

| Spec requirement | Task |
|------------------|------|
| Phase 0 rebrand | Task 1 |
| Delete site/index.html | Task 1 |
| Monorepo apps/web | Tasks 2–3 |
| Next.js + Vercel | Tasks 3, 9, 13 |
| Caveman-style landing | Task 11 |
| Free single-skill zip audit | Tasks 6–7, 9 |
| Anonymous (no auth Phase 1) | Task 12 (sessionStorage) |
| MD download | Task 8, 12 |
| Bash govern scripts | Task 7 |
| Rate limit | Task 9 |
| engine_version in response | Task 7, 9 |
| Pricing Early access | Task 11 |
| OSS CI unchanged + web tests | Task 13 |
| GitHub repo rename | Task 1 Step 10 note (manual) |

**Deferred to Phase 2+ (intentionally out of plan):** Neon DB, Auth.js, Stripe, mutation, library scan.

### Placeholder scan

No TBD/TODO steps. All code blocks complete.

### Type consistency

- `AuditReport`, `SkillAuditResult`, `Verdict` used consistently across lib, API, components.
- `saveReport` / `loadReport` share `STORAGE_PREFIX` in SkillDropzone.
- `getRepoRoot()` used by run-audit and integration tests.

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-06-16-skillsteroids-phase0-phase1.md`.

**Two execution options:**

1. **Subagent-Driven (recommended)** — fresh subagent per task, review between tasks, fast iteration

2. **Inline Execution** — execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**
