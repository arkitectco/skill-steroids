# SkillSteroids

**A modular, markdown-first meta-framework for deliberately evolving your AI agent skill library over time.**

**Headline metrics:** `./plugin/skills/skill-steroids/scripts/stats.sh` — structural health %, open gaps, unresolved BLOCKs (see [metrics.md](plugin/skills/skill-steroids/metrics.md)).

Install the **plugin** — see [INSTALL.md](INSTALL.md). There is no separate skill-pack install.

This framework turns ad-hoc skill creation and occasional cleanup into a structured, compounding evolutionary process.

## Vision

Move from ad-hoc skill creation to a **governed audit and mutation workflow** that compounds improvement over time.

v1 delivers **audit + governed mutation**, not autonomous evolution. See [Framework Vision](docs/FRAMEWORK_VISION.md) for long-term goals.

## Current Status

**v2.3.1** — Plugin marketplace install (`./plugin`) plus governed audit/mutate loop, SessionStart bootstrap, and golden evals.

## Web app (MicroSaaS)

```bash
cd apps/web && npm run dev
```

Open http://localhost:3000 — landing + free skill audit studio.

## Key Principles

- **Markdown-first** — Core logic lives in well-structured `SKILL.md` files.
- **Modular & Composable** — Small, focused skills rather than monolithic systems.
- **Principle-Driven** — A living `principles.md` acts as the constitution.
- **Human-in-the-Loop** (v1) — Strong oversight with room to increase autonomy later.
- **Self-Improving** — The framework itself should be subject to the same evolutionary process.

## Repository Structure

```
SkillSteroids/
├── apps/web/                   # MicroSaaS (Next.js)
├── plugin/                     # Marketplace install surface
│   ├── skills/skill-steroids/  # Skill content (orchestrator → lineage)
│   ├── commands/               # /skill-steroids:audit, :mutate
│   └── hooks/
├── evals/                      # CI golden fixtures
└── docs/
```

## Getting Started

1. Read the [Framework Vision](docs/FRAMEWORK_VISION.md)
2. Install via [INSTALL.md](INSTALL.md); agent loop spec is [plugin/skills/skill-steroids/SKILL.md](plugin/skills/skill-steroids/SKILL.md)
3. In a new agent chat, ask **"skill steroids audit"**
4. Validate with [falsification test](docs/demo-audit.md) before trusting proposals on your library

Create uses `plugin/skills/skill-steroids/templates/skill-template.md`. Review uses `plugin/skills/skill-steroids/references/skill-review-rubric.md`.

## Install

See [INSTALL.md](INSTALL.md). From a clone:

```bash
./plugin/skills/skill-steroids/scripts/doctor.sh
./evals/run-eval.sh
./plugin/skills/skill-steroids/scripts/stats.sh
```

In a new agent chat, ask **"skill steroids audit"** (reports only) or **"skill steroids mutate"** (one governed change).

## Plugin packaging

Marketplace surface is `./plugin`. Grok: `grok plugin install arkitectco/skill-steroids#plugin --trust`. See [PUBLISHING.md](docs/PUBLISHING.md).

Plugin installs inject `using-skill-steroids` at session start. The full audit/mutate loop runs only when you ask.

## Scripts Policy

This framework prefers pure `SKILL.md` files. Scripts are only added when they provide significant practical value that markdown cannot easily deliver (e.g. scanning many files, logging, or validation).

## Contributing / Building

This project is intended to be evolved using its own principles. When working on it:

- Use the in-plugin Evolver template (`plugin/skills/skill-steroids/templates/skill-template.md`) for new components
- Use the Analyzer/Governor patterns
- Keep changes small, principled, and well-documented

## License

MIT — see [LICENSE](LICENSE).

---

*Built collaboratively on June 2026. Designed to compound in capability over time.*
