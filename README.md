# Skill Botox Evolution Framework

**A modular, markdown-first meta-framework for deliberately evolving your AI agent skill library over time.**

**Headline metric:** `./scripts/stats.sh` reports structural health (% skills passing govern-check).

**One-line install:**

```bash
curl -fsSL https://raw.githubusercontent.com/arkitectco/SkillBotox/main/install.sh | bash
```

See [INSTALL.md](INSTALL.md) for all agents.

This framework turns ad-hoc skill creation and occasional cleanup into a structured, compounding evolutionary process.

## Vision

Move from manual skill crafting to a closed-loop system that can:

- Observe real usage and friction
- Analyze the entire library for gaps, redundancy, and drift
- Govern changes against explicit principles
- Evolve and mutate skills intelligently
- Experiment safely
- Maintain lineage and institutional knowledge

The long-term goal is for this to become the **meta-operating system** for your personal agentic capabilities.

## Current Status

**v1.1.0** — Phase A trust layer: install script, doctor, eval harness, structural health stats.

## Key Principles

- **Markdown-first** — Core logic lives in well-structured `SKILL.md` files.
- **Modular & Composable** — Small, focused skills rather than monolithic systems.
- **Principle-Driven** — A living `principles.md` acts as the constitution.
- **Human-in-the-Loop** (v1) — Strong oversight with room to increase autonomy later.
- **Self-Improving** — The framework itself should be subject to the same evolutionary process.

## Repository Structure

```
SkillBotox/
├── README.md
├── SKILL.md                    # Root orchestrator entry point
├── HANDOFFER.md                # Detailed context for future agents
├── evolution.md
├── principles.md
├── metrics.md
├── docs/
│   ├── FRAMEWORK_VISION.md
│   └── PRD-skill-botox-Framework.md
├── templates/
│   └── skill-template.md
├── orchestrator/
├── observer/
├── analyzer/
├── evolver/
├── governor/
├── experimenter/
├── lineage/
├── references/
└── scripts/                    # Lightweight helpers only (optional)
```

## Getting Started

1. Read the [PRD](docs/PRD-skill-botox-Framework.md)
2. Read the [Framework Vision](docs/FRAMEWORK_VISION.md)
3. Review [HANDOFFER.md](HANDOFFER.md) for implementation guidance
4. Install the skill pack (see below)
5. In a new agent chat, ask **"run skill botox"**

Existing high-quality meta-skills (`skill-architect` and `skill-destroyer`) are delegated to, not duplicated.

## Install

```bash
./install.sh
```

Or symlink manually:

```bash
ln -sf "$(pwd)" ~/.cursor/skills/skill-botox
```

Verify:

```bash
./scripts/doctor.sh
./evals/run-eval.sh
./scripts/stats.sh
```

In a new agent chat, ask **"run skill botox"**.

## Uninstall

```bash
./install.sh --uninstall
```

## Plugin packaging

For Cursor plugin distribution, see `.cursor-plugin/plugin.json`. Skills remain in this repo root; the manifest wraps the pack for marketplace or local plugin install.

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