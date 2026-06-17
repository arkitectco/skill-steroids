# SkillSteroids Framework — Agent Handoff / Context Package

**Date**: June 15, 2026  
**Status**: Scaffold — Ready for Implementation  
**Goal**: Turn this scaffold into a production-ready, self-improving skill steroids system.

## Context from User

This framework builds on existing `skill-architect` and `skill-destroyer` skills. The user wants a complete evolutionary loop rather than isolated tools.

## What to Build (Priority Order)

1. **Core Orchestrator** (`SKILL.md` at root — already stubbed)
2. **Governor** — Enforces principles
3. **Analyzer** — Library-wide systemic review (evolves skill-destroyer)
4. **Evolver** — Mutation + creation (builds on skill-architect)
5. **Observer** — Usage telemetry and friction capture
6. **Experimenter** — Safe A/B testing
7. **Lineage** — Versioning and knowledge retention

## Key Files to Complete

- `evolution.md` — Overall loop description and decision logic
- `principles.md` — Living skill constitution (very important)
- `metrics.md` — Objective success/friction signals
- Individual `SKILL.md` in each subdirectory
- `templates/skill-template.md` — Standardized new skill starter

## Design Guidelines (from PRD + Vision)

- Keep skills small, focused, and composable (markdown-first)
- Strong human-in-the-loop for v1
- All changes must pass through Governor
- Integrate cleanly with existing meta-skills (`skill-architect` + `skill-destroyer`)
- Scripts are optional and should only be added when markdown alone is insufficient (see PRD for policy)
- Follow the same quality standards you would apply via skill-architect
- Make the framework itself subject to evolution (dogfood it)
- See the root `README.md` for overall project context

## Success Criteria

- The system can take real usage context and produce actionable, principled recommendations
- New skills created via Evolver are high-quality and consistent
- Governor catches principle violations reliably
- The loop feels deliberate and compounding rather than random

## Next Actions for Incoming Agent

1. Flesh out `principles.md` based on user's values (modularity, clarity, low bloat, declarative patterns, etc.)
2. Implement Governor first — it's the quality gate
3. Build Orchestrator to coordinate everything
4. Create a simple Observer that works with conversation history or explicit signals
5. Test the loop with sample usage data

You have full context from the docs/ folder. Build iteratively and use the existing skill-architect and skill-destroyer where appropriate.

This handoff is designed so any capable agent (including future versions of yourself) can pick it up and make meaningful progress.