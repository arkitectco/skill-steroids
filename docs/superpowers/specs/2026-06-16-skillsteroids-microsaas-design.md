# SkillSteroids MicroSaaS — Design Spec

**Status:** Approved (brainstorming 2026-06-16)  
**Replaces branding:** Skill Botox → SkillSteroids  
**Product type:** MicroSaaS (site = product), not marketing-only

---

## Summary

SkillSteroids is a freemium MicroSaaS for auditing and improving AI agent skill libraries. Users upload skill folder zips, receive Governor-style structural and semantic verdicts for free, and upgrade for AI-guided mutation, saved runs, and multi-skill library scans. The existing markdown-first skill pack remains the open-source power-user path in the same monorepo.

**Tagline (default):** *Stack your agent skills.*

**Thesis line:** *[thesis] why skill debt when skill can compound.*

---

## Decisions log

| Topic | Decision |
|-------|----------|
| Product shape | MicroSaaS — landing + in-browser product |
| Brand | **SkillSteroids** (not SkillSteriods) |
| Monetization | Freemium |
| Free tier | Deterministic audit only (no AI inference) |
| Paid tier | AI mutation, saved runs, multi-skill library zip scan, export bundles |
| Auth | Soft account — anonymous audit; magic link to save or upgrade |
| Free upload | Single-skill folder zip (must contain `SKILL.md`) |
| Paid library scan | Multi-skill zip (no GitHub in v1) |
| Inference | Hybrid — mutation quota in subscription; BYOK or top-up for overage |
| Repo | Rebrand in place; `apps/web/` for SaaS; OSS skill pack retained |
| Stack | Next.js (App Router) + Vercel |
| Audit engine v1 | Shell existing `scripts/govern-check.sh` + `govern-semantic-check.sh` |
| Audit engine v1.1+ | `packages/audit-core` TypeScript port |
| UI reference | [getcaveman.dev](https://getcaveman.dev) — dark, `§` sections, terminal demos; distinct amber accent |

---

## Section 1 — Product surfaces & flows

### Surfaces

1. **Marketing shell** — Caveman-inspired landing: hero, ecosystem, Governor demo, pricing, proof (CI, MIT, OSS pack).
2. **Studio** (`/studio`) — upload, reports, mutation (paid), dashboard (authenticated).
3. **OSS path** — `install.sh`, Cursor plugin, agent triggers (`skill steroids audit`) for local/agent use.

### Free flow (anonymous)

1. Land → **Audit a skill**.
2. Upload single-skill zip (`SKILL.md` required).
3. Server extracts → runs govern structural + semantic checks → renders report.
4. Download report (MD). **Save** or **Mutate** prompts magic-link email.

### Paid flow

1. Audit + persisted runs in dashboard.
2. **Mutate** — AI proposal → diff → Governor re-check → approve → download zip (one mutation per run).
3. **Library scan** — multi-skill zip → aggregate report (max 5 deep reviews, 3 proposals).
4. Quota meter; at limit → BYOK or top-up.

### Pricing sketch

| Tier | Includes |
|------|----------|
| **Free** | Unlimited structural audits; no persistence unless magic link save |
| **Pro** | N mutations/month (default 10, TBD), saved runs, library scan, export; overage via BYOK/top-up |

Phase 1 may show **Early access** pricing until numbers are set.

---

## Section 2 — Architecture

### Monorepo layout

```
SkillSteroids/
├── apps/web/                 # Next.js MicroSaaS (Vercel)
├── packages/audit-core/      # v1.1 — TS port of govern rules
├── orchestrator/ …           # OSS skill modules
├── scripts/                  # govern-check, semantic-check, stats, evals
├── evals/                    # CI golden fixtures (source of truth)
├── principles.md             # Governor constitution
└── .cursor-plugin/
```

Web builds import or generate a manifest from `principles.md` + `metrics.md` so verdicts match OSS Governor.

### `apps/web` routes

| Route | Purpose |
|-------|---------|
| `/` | Marketing landing |
| `/pricing` | Free vs Pro |
| `/docs`, `/changelog` | OSS install, falsification test, releases |
| `/studio` | Upload + dashboard |
| `/studio/runs/[id]` | Audit report |
| `/studio/mutate/[id]` | Paid diff flow |
| `/studio/library` | Paid multi-skill scan |
| `/api/audit` | POST zip → audit |
| `/api/runs` | GET saved runs (auth) |
| `/api/mutate` | POST mutation job (paid + quota) |
| `/api/library` | POST multi-skill zip (paid) |
| `/api/stripe/*` | Checkout + webhooks |

### Data model (Neon Postgres)

**users** — id, email, stripe_customer_id, plan (`free` | `pro`), mutation_quota_used, byok_key_encrypted (nullable)

**runs** — id, user_id (nullable), type (`audit` | `library` | `mutate`), status, created_at

**run_artifacts** — run_id, report_json, zip_storage_key

**mutations** — run_id, diff_text, governor_verdict, status (`draft` | `approved` | `exported`)

**subscriptions** — stripe_subscription_id, period_end, included_mutations

Anonymous runs: `user_id = null`, blob TTL 24h; magic-link save copies to user.

### Audit pipeline

```
ZIP → validate size/structure → extract to temp dir
  → govern-check.sh per SKILL.md
  → govern-semantic-check.sh per skill
  → aggregate PASS/WARN/BLOCK
  → report_json + UI render
```

**Limits:**

| Mode | Zip |
|------|-----|
| Free audit | 1 skill folder, max 500KB |
| Library scan (paid) | up to 50 skills, max 5MB |

### Mutation pipeline (paid)

```
audit with proposals → quota/BYOK check
  → LLM (evolver + governor prompts)
  → draft diff + semantic re-check
  → user approves → export zip → decrement quota
```

### Auth & billing

- **Auth:** Auth.js v5 magic link
- **Payments:** Stripe Checkout + Customer Portal
- **Entitlements:** webhook sets `plan=pro`, resets monthly quota
- **BYOK:** encrypted at rest; used only in mutation route

### Deployment

| Component | Host |
|-----------|------|
| Next.js | Vercel |
| Postgres | Neon |
| Zip blobs | Vercel Blob or R2 |
| Long jobs | Vercel maxDuration first; Inngest if timeouts |

### Traceability

API responses include `engine_version` (git SHA). Marketing cites same evals as OSS CI.

---

## Section 3 — UI & brand

### Voice

Technical confidence + light irreverence. Performance metaphor for skill libraries. Use PASS/WARN/BLOCK language. No medical scam vibes or vague AI hype.

### Visual tokens

- Background: `#0a0a0b` + grain
- Accent: electric amber/gold
- Status: green / amber / red
- Fonts: Instrument Serif (display), DM Sans (body), JetBrains Mono (code)
- Patterns: `§ NN · Label`, terminal blocks, staggered scroll reveal

### Key screens

1. **Landing** — hero, ecosystem cards, studio demo, Governor comparison, pricing, proof
2. **Studio upload** — drag-drop zip, progress steps
3. **Audit report** — verdict summary, violation table, download/save/upgrade CTAs
4. **Mutation** — diff viewer, Governor verdict, approve & download
5. **Library scan** — multi-skill summary, top proposals
6. **Dashboard** — runs, quota, settings (Stripe portal, BYOK)

### Shared components

`SectionLabel`, `TerminalBlock`, `VerdictBadge`, `SkillDropzone`, `PrincipleTable`, `DiffViewer`, `QuotaMeter`, `PricingTable`

### UX rules

- Audit before signup
- Verdict before AI prose
- One mutation per run
- Free tier honestly deterministic
- Studio desktop-first

---

## Section 4 — Phasing

### Phase 0 — Rebrand (1–2 days)

Rename to SkillSteroids; remove `site/index.html`; monorepo scaffold; CI unchanged.

### Phase 1 — Landing + free audit (MVP)

Marketing + anonymous single-skill audit + MD download. No Stripe, no mutation.

**Success:** audit in &lt;60s without account.

### Phase 2 — Soft auth + save runs

Magic link, dashboard, persist runs.

### Phase 3 — Pro tier

Stripe, mutation, quota, BYOK, export zip.

### Phase 4 — Library scan

Multi-skill zip, Analyzer-style report.

### Phase 5 — Hardening

`packages/audit-core`, job queue, optional GitHub connect (v1.1).

### Out of scope v1

- GitHub repo scanning
- Agent telemetry / Observer automation
- Autonomous writes without diff approval
- Mobile studio app
- Team accounts

---

## Security

| Risk | Mitigation |
|------|------------|
| Zip bombs | Size caps, file count, extract timeout |
| Path traversal | Sanitized extract paths |
| Upload privacy | No training on user content; clear policy |
| BYOK leakage | Encrypt; never log |
| Anonymous abuse | IP rate limits (10 audits/hr); CAPTCHA if needed |
| Unsafe mutations | Governor BLOCK prevents export |

---

## Testing

- CI: existing `evals/run-eval.sh` on every PR
- Web integration: POST golden fixture zips; assert verdict parity with bash
- API: Vitest on audit routes
- Stripe: CLI webhook tests
- E2E (Phase 2+): Playwright upload → report

**Regression rule:** Web verdicts must match `govern-check.sh` for all golden fixtures.

---

## Rebrand checklist

- [ ] GitHub repo rename SkillBotox → SkillSteroids
- [ ] `skill-botox` → `skill-steroids` in SKILL names and install paths
- [ ] README, CHANGELOG, plugin.json, HANDOFFER
- [ ] Domain: `skillsteroids.dev` (placeholder until purchased)
- [ ] Delete `site/index.html` (premature static site)

---

## Open items (non-blocking)

| Item | Default |
|------|---------|
| Pro monthly price | TBD — Early access in Phase 1 |
| Mutation quota | 10/month Pro (adjust after cost data) |
| Blob provider | Vercel Blob unless R2 preferred later |

---

## Next step

After spec approval: invoke **writing-plans** for Phase 0 + Phase 1 implementation plan.
