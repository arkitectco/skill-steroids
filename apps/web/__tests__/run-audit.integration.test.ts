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
