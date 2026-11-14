import fs from "fs";
import path from "path";
import { getPackRoot } from "./paths";
import { PACK_MODULES, type PackModulePath } from "./manifest";

export { PACK_MODULES, type PackModulePath };

export function loadSkillMarkdown(relPath: PackModulePath | string): string {
  const full = path.join(getPackRoot(), relPath);
  if (!fs.existsSync(full)) {
    throw new Error(`Pack file not found: ${relPath}`);
  }
  return fs.readFileSync(full, "utf8");
}

export function loadPrinciples(): string {
  return loadSkillMarkdown("principles.md");
}

export function loadOrchestratorPrompt(): string {
  return loadSkillMarkdown("orchestrator/SKILL.md");
}

export function loadGovernorPrompt(): string {
  return loadSkillMarkdown("governor/SKILL.md");
}

export function loadEvolverPrompt(): string {
  return loadSkillMarkdown("evolver/SKILL.md");
}
