import { execFile } from "child_process";
import fs from "fs";
import path from "path";
import { promisify } from "util";
import { getRepoRoot } from "@/lib/repo-root";
import { aggregateVerdict, mergeRules, parseGovernOutput } from "./parse-govern";
import type { AuditReport, SkillAuditResult } from "./types";
import { cleanupExtractDir, extractSkillZip, findSkillMdFiles } from "./zip";

const execFileAsync = promisify(execFile);

async function runScript(script: string, args: string[]): Promise<string> {
  const repo = getRepoRoot();
  const scriptPath = path.join(repo, "scripts", script);
  try {
    const { stdout, stderr } = await execFileAsync("bash", [scriptPath, ...args], {
      cwd: repo,
      timeout: 30_000,
    });
    return `${stdout}\n${stderr}`;
  } catch (err: unknown) {
    const execErr = err as NodeJS.ErrnoException & { stdout?: string; stderr?: string };
    if (execErr.stdout !== undefined || execErr.stderr !== undefined) {
      return `${execErr.stdout ?? ""}\n${execErr.stderr ?? ""}`;
    }
    throw err;
  }
}

function isOrchestratorSkill(filePath: string, content: string): boolean {
  return (
    filePath.includes("orchestrator") ||
    /orchestrator/i.test(content.slice(0, 500))
  );
}

function readSkillName(content: string): string {
  const m = content.match(/^name:\s*(.+)$/m);
  return m ? m[1].trim().replace(/^["']|["']$/g, "") : "unknown";
}

export async function runAuditOnSkillFile(skillPath: string): Promise<SkillAuditResult> {
  const content = fs.readFileSync(skillPath, "utf8");
  const orchFlag = isOrchestratorSkill(skillPath, content) ? ["--orchestrator"] : [];

  const structuralOut = await runScript("govern-check.sh", [skillPath, ...orchFlag]);
  const semanticOut = await runScript("govern-semantic-check.sh", [skillPath]);

  const structural = parseGovernOutput(structuralOut);
  const semantic = parseGovernOutput(semanticOut);
  const all = mergeRules(structural, semantic);

  return {
    skillPath,
    skillName: readSkillName(content),
    structural,
    semantic,
    verdict: aggregateVerdict(all),
    lineCount: content.split("\n").length,
  };
}

export async function runAuditFromZip(
  zipBuffer: Buffer,
  engineVersion: string
): Promise<AuditReport> {
  const extractDir = extractSkillZip(zipBuffer, { maxBytes: 500_000, maxSkills: 1 });
  try {
    const skillFiles = findSkillMdFiles(extractDir);
    const skills: SkillAuditResult[] = [];
    for (const file of skillFiles) {
      skills.push(await runAuditOnSkillFile(file));
    }
    const passCount = skills.filter((s) => s.verdict === "PASS").length;
    const blockCount = skills.filter((s) => s.verdict === "BLOCK").length;
    return {
      runId: crypto.randomUUID(),
      engineVersion,
      createdAt: new Date().toISOString(),
      skills,
      summary: {
        structuralHealthPct: skills.length
          ? Math.round((passCount / skills.length) * 100)
          : 0,
        passCount,
        blockCount,
        warnCount: 0,
      },
    };
  } finally {
    cleanupExtractDir(extractDir);
  }
}
