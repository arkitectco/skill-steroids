# PRD: SkillSteroids Framework

**Status**: Draft — Ready for implementation  
**Date**: June 14, 2026  
**Owner**: arkitectco

---

## Problem Statement

The user has two valuable but isolated meta-skills (`skill-architect` for creation and `skill-destroyer` for review/pruning). These tools are helpful in isolation but do not form a complete, closed-loop system for managing and improving a growing library of skills over time.

As the number and complexity of skills increases, there is no systematic way to:
- Observe real usage and friction
- Detect systemic issues across the library (gaps, redundancy, principle drift)
- Experiment safely with improvements
- Enforce consistent principles and quality
- Track successful mutations and retain knowledge from changes

This leads to skill debt, inconsistent quality, and missed opportunities for compounding improvement in the user’s agentic capabilities.

## Solution

Create a new modular **SkillSteroids Framework** — a meta-layer that turns skill management into a deliberate evolutionary process.

The framework will include:
- A lightweight **orchestrator**
- Specialized sub-skills for **observation, analysis, evolution/mutation, governance, safe experimentation, and lineage tracking**

It will integrate with and enhance the existing `skill-architect` and `skill-destroyer` while adding the missing feedback loops and governance.

## User Stories

1. As a power user building many custom skills, I want the system to observe my actual usage patterns and friction points so that I can see where my skills are (or aren’t) helping me.
2. As someone maintaining a growing skill library, I want periodic or triggered analysis that identifies gaps, overlaps, principle drift, and underperforming skills.
3. As a user who values coherence, I want every proposed change to be checked against my evolving principles.
4. As someone who experiments, I want to safely test skill variations and measure real impact before committing.
5. As a long-term user, I want successful improvements and lessons from pruned skills to be recorded so knowledge compounds.
6. As a user who wants evolution without constant manual work, I want an orchestrator that decides when analysis or changes are needed.
7. As the owner of this system, I want clear metrics so that “improvement” is objective.
8. As a user working on complex projects, I want high-leverage opportunities surfaced based on real work patterns.
9. As someone who already uses `skill-architect` and `skill-destroyer`, I want the framework to enhance and route through them rather than replace them.
10. As a user building modular systems, I want the framework itself to follow clean architectural patterns.

## Implementation Decisions

- Deliver as a modular, installable skill pack following the SKILL.md + supporting files pattern (markdown-first philosophy).
- Core components: Orchestrator + Observer, Analyzer, Evolver, Governor, Experimenter, Lineage.
- `skill-architect` will be invoked by the Evolver for new skill creation.
- `skill-destroyer` will be complemented/evolved by the Analyzer for systemic reviews.
- A living `principles.md` will serve as the governance source of truth.
- `metrics.md` will define objective signals for friction, success, health, and improvement.
- `evolution.md` will document the loop and decision logic.
- All changes flow through the Governor before recommendation or application.
- Support both human-in-the-loop and increasing autonomy.
- Lineage tracking preserves knowledge without bloating the active library.
- Designed to work alongside Superpowers, GSD, Matt Pocock’s skills, etc.
- **Scripts policy**: The framework is markdown-first. Lightweight helper scripts (in `scripts/`) are allowed only when they provide clear value that pure SKILL.md files cannot easily achieve (e.g., skill inventory scanning, principle validation, usage logging for the Observer, or basic lineage tracking). Scripts are **not required in v1** and should remain minimal and optional.

## Testing Decisions

- Focus on quality and actionability of outputs (Analyzer recommendations, Evolver proposals).
- Verify correct identification of friction/gaps from usage signals.
- Test Governor for consistent principle enforcement.
- Validate clean integration with `skill-architect` and `skill-destroyer`.
- Test evolution loops with both simulated and real conversation contexts.
- Prior art: structured review style of `skill-destroyer`, modular patterns of `skill-architect`, and composable design from established skill frameworks.

## Out of Scope (v1)

- Full autonomous execution of skill changes without user oversight.
- Deep integration with external trackers beyond existing skill capabilities.
- Automatic rewriting of all existing skills.
- Real-time continuous observation (periodic or triggered runs in v1).
- Building a full Personal Agent Overseer (this can feed into one later).

## Further Notes

This framework should create **compounding returns** on the skill library over time. It should be built modularly so individual components can evolve independently while maintaining a coherent whole.

The long-term vision is for this to become the meta-operating system for skill library health and improvement.

---

**Ready for agent implementation.**