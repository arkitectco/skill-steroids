import { describe, it, expect } from "vitest";
import { parseGovernOutput, aggregateVerdict } from "@/lib/audit/parse-govern";

describe("parseGovernOutput", () => {
  it("parses PASS and FAIL lines", () => {
    const out = `  PASS P-02
  FAIL P-03: SKILL.md has 520 lines (>500)
  PASS P-05`;
    const rules = parseGovernOutput(out);
    expect(rules).toEqual([
      { principle: "P-02", pass: true },
      { principle: "P-03", pass: false, message: "SKILL.md has 520 lines (>500)" },
      { principle: "P-05", pass: true },
    ]);
  });
});

describe("aggregateVerdict", () => {
  it("returns BLOCK when any rule fails", () => {
    expect(aggregateVerdict([{ principle: "P-02", pass: true }])).toBe("PASS");
    expect(
      aggregateVerdict([
        { principle: "P-02", pass: true },
        { principle: "P-03", pass: false, message: "bloated" },
      ])
    ).toBe("BLOCK");
  });
});
