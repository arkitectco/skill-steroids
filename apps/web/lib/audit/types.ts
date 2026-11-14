export type Verdict = "PASS" | "WARN" | "BLOCK";

export interface RuleResult {
  principle: string;
  pass: boolean;
  message?: string;
}

export interface SkillAuditResult {
  skillPath: string;
  skillName: string;
  structural: RuleResult[];
  semantic: RuleResult[];
  verdict: Verdict;
  lineCount: number;
}

export interface AuditReport {
  runId: string;
  engineVersion: string;
  createdAt: string;
  skills: SkillAuditResult[];
  summary: {
    structuralHealthPct: number;
    passCount: number;
    blockCount: number;
    warnCount: number;
  };
}
