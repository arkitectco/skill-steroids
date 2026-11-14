import { describe, it, expect } from "vitest";
import { auditReportToMarkdown } from "@/lib/audit/report-md";
import type { AuditReport } from "@/lib/audit/types";

const sample: AuditReport = {
  runId: "test-run",
  engineVersion: "abc123",
  createdAt: "2026-06-16T00:00:00.000Z",
  skills: [
    {
      skillPath: "/tmp/s/SKILL.md",
      skillName: "demo",
      structural: [{ principle: "P-02", pass: true }],
      semantic: [{ principle: "P-01", pass: true }],
      verdict: "PASS",
      lineCount: 42,
    },
  ],
  summary: { structuralHealthPct: 100, passCount: 1, blockCount: 0, warnCount: 0 },
};

describe("auditReportToMarkdown", () => {
  it("includes run id and verdict", () => {
    const md = auditReportToMarkdown(sample);
    expect(md).toContain("test-run");
    expect(md).toContain("PASS");
    expect(md).toContain("demo");
  });
});
