import { describe, it, expect } from "vitest";
import fs from "fs";
import path from "path";
import { getPackRoot, getRepoRoot } from "@/lib/pack/paths";

describe("pack paths", () => {
  it("getPackRoot resolves to packages/skill-pack with govern script", () => {
    const pack = getPackRoot();
    const govern = path.join(pack, "scripts/govern-check.sh");
    expect(fs.existsSync(govern)).toBe(true);
  });

  it("getRepoRoot resolves to monorepo root with evals", () => {
    const repo = getRepoRoot();
    expect(fs.existsSync(path.join(repo, "evals/run-eval.sh"))).toBe(true);
  });
});
