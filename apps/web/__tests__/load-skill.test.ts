import { describe, it, expect } from "vitest";
import { loadSkillMarkdown, loadPrinciples, PACK_MODULES } from "@/lib/pack/load-skill";

describe("load-skill", () => {
  it("lists core pack modules", () => {
    expect(PACK_MODULES).toContain("governor/SKILL.md");
    expect(PACK_MODULES).toContain("orchestrator/SKILL.md");
    expect(PACK_MODULES).toContain("evolver/SKILL.md");
  });

  it("loads governor SKILL.md with frontmatter", () => {
    const md = loadSkillMarkdown("governor/SKILL.md");
    expect(md).toMatch(/^---/);
    expect(md).toContain("Governor");
  });

  it("loads principles.md", () => {
    const md = loadPrinciples();
    expect(md).toContain("P-02");
  });
});
