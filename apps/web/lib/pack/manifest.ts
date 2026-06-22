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
