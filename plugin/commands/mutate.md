---
name: mutate
description: Run SkillSteroids in mutate mode — one Governor-approved skill change. Use when the user says skill steroids mutate, evolve skill X, or /skill-steroids mutate.
---

Load the `skill-steroids` skill and execute the orchestrator in **mutate** mode.

Follow `orchestrator/SKILL.md` from Step 0. Cap at 3 proposals; Governor must verdict each one. Ask the user to approve **one** proposal (or none). Confirm before every filesystem write or delete. Record lineage after any applied change.
