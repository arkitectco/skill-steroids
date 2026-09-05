# SkillSteroids

**A modular, markdown-first meta-framework for deliberately evolving your AI agent skill library over time.**

**Headline metrics:** `./plugin/skills/skill-steroids/scripts/stats.sh` — structural health %, open gaps, unresolved BLOCKs (see [metrics.md](plugin/skills/skill-steroids/metrics.md)).

**One-line install:**

```bash
curl -fsSL https://raw.githubusercontent.com/arkitectco/skill-steroids/main/install.sh | bash
```

See [INSTALL.md](INSTALL.md) for all agents.

This framework turns ad-hoc skill creation and occasional cleanup into a structured, compounding evolutionary process.

## Vision

Move from ad-hoc skill creation to a **governed audit and mutation workflow** that compounds improvement over time.

v1 delivers **audit + governed mutation**, not autonomous evolution. See [Framework Vision](docs/FRAMEWORK_VISION.md) for long-term goals.

## Current Status

**v1.2.0** — Phase B audit hardening: run persistence, dual metrics, semantic evals, audit/mutate modes.

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
│   ├── skills/skill-steroids/  # Skill pack (orchestrator → lineage)
│   ├── commands/               # /skill-steroids:audit, :mutate
│   └── hooks/
├── evals/                      # CI golden fixtures
├── docs/
└── install.sh                  # symlink fallback → plugin/skills/skill-steroids
```

## Getting Started

1. Read the [PRD](docs/PRD-skill-steroids-Framework.md)
2. Read the [Framework Vision](docs/FRAMEWORK_VISION.md)
3. Review [HANDOFFER.md](HANDOFFER.md) for implementation guidance
4. Install the skill pack (see below)
5. In a new agent chat, ask **"skill steroids audit"**
6. Validate with [falsification test](docs/demo-audit.md) before trusting proposals on your library

Existing high-quality meta-skills (`skill-architect` and `skill-destroyer`) are delegated to, not duplicated.

## Install

```bash
./install.sh
```

Or symlink manually:

```bash
ln -sfn "$(pwd)/plugin/skills/skill-steroids" ~/.cursor/skills/skill-steroids
```

Verify:

```bash
./plugin/skills/skill-steroids/scripts/doctor.sh
./evals/run-eval.sh
./plugin/skills/skill-steroids/scripts/stats.sh
```

In a new agent chat, ask **"skill steroids audit"** (reports only) or **"skill steroids mutate"** (one governed change).

## Uninstall

```bash
./install.sh --uninstall
```

## Plugin packaging

Primary install is the plugin marketplace (`./plugin`). Grok: `grok plugin install arkitectco/skill-steroids#plugin --trust`. Use `./install.sh` as the symlink fallback onto `plugin/skills/skill-steroids`. See [PUBLISHING.md](docs/PUBLISHING.md).

Plugin installs inject `using-skill-steroids` at session start (SessionStart hooks). The full audit/mutate loop runs only when you ask.

## Scripts Policy

This framework prefers pure `SKILL.md` files. Scripts are only added when they provide significant practical value that markdown cannot easily deliver (e.g. scanning many files, logging, or validation). See the PRD for details.

## Contributing / Building

This project is intended to be evolved using its own principles. When working on it:

- Use `skill-architect` for creating new components
- Use the Analyzer/Governor patterns once implemented
- Keep changes small, principled, and well-documented

## License

MIT — see [LICENSE](LICENSE).

---

*Built collaboratively on June 2026. Designed to compound in capability over time.*