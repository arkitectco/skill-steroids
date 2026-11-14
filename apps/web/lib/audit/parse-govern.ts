import type { RuleResult, Verdict } from "./types";

const LINE_RE = /^\s+(PASS|FAIL)\s+(P-\d+)(?::\s*(.+))?$/;

export function parseGovernOutput(output: string): RuleResult[] {
  const results: RuleResult[] = [];
  for (const line of output.split("\n")) {
    const m = line.match(LINE_RE);
    if (!m) continue;
    results.push({
      principle: m[2],
      pass: m[1] === "PASS",
      message: m[3]?.trim(),
    });
  }
  return results;
}

export function aggregateVerdict(rules: RuleResult[]): Verdict {
  if (rules.some((r) => !r.pass)) return "BLOCK";
  return "PASS";
}

export function mergeRules(...groups: RuleResult[][]): RuleResult[] {
  const map = new Map<string, RuleResult>();
  for (const group of groups) {
    for (const r of group) map.set(r.principle, r);
  }
  return [...map.values()].sort((a, b) => a.principle.localeCompare(b.principle));
}
