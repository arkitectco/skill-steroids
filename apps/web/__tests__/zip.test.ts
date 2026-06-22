import { describe, it, expect } from "vitest";
import AdmZip from "adm-zip";
import fs from "fs";
import os from "os";
import path from "path";
import { extractSkillZip, findSkillMdFiles } from "@/lib/audit/zip";

function makeZip(files: Record<string, string>): Buffer {
  const zip = new AdmZip();
  for (const [name, content] of Object.entries(files)) {
    zip.addFile(name, Buffer.from(content, "utf8"));
  }
  return zip.toBuffer();
}

describe("extractSkillZip", () => {
  it("rejects zip without SKILL.md", () => {
    const buf = makeZip({ "readme.txt": "hi" });
    expect(() => extractSkillZip(buf, { maxBytes: 500_000, maxSkills: 1 })).toThrow(
      /SKILL\.md/
    );
  });

  it("extracts single skill with SKILL.md", () => {
    const buf = makeZip({
      "my-skill/SKILL.md": "---\nname: test\n---\n# Test",
    });
    const dir = extractSkillZip(buf, { maxBytes: 500_000, maxSkills: 1 });
    expect(findSkillMdFiles(dir)).toHaveLength(1);
    fs.rmSync(dir, { recursive: true, force: true });
  });

  it("rejects path traversal entries", () => {
    const zip = new AdmZip();
    zip.addFile("../../../etc/passwd", Buffer.from("bad"));
    zip.addFile("skill/SKILL.md", Buffer.from("---\nname: x\n---\n"));
    // adm-zip sanitizes paths on addFile; restore traversal path for zip-slip test
    const evil = zip.getEntries().find((e) => e.entryName === "etc/passwd");
    if (evil) evil.entryName = "../../../etc/passwd";
    expect(() =>
      extractSkillZip(zip.toBuffer(), { maxBytes: 500_000, maxSkills: 1 })
    ).toThrow(/traversal/);
  });
});
