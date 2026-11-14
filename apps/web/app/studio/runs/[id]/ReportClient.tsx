"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { loadReport } from "@/components/SkillDropzone";
import { VerdictBadge } from "@/components/VerdictBadge";
import { auditReportToMarkdown } from "@/lib/audit/report-md";
import type { AuditReport } from "@/lib/audit/types";

export function ReportClient({ runId }: { runId: string }) {
  const [report, setReport] = useState<AuditReport | null>(null);

  useEffect(() => {
    setReport(loadReport(runId));
  }, [runId]);

  if (!report) {
    return (
      <p style={{ color: "var(--text-muted)" }}>
        Report not found in this session. <Link href="/studio">Run a new audit</Link>.
      </p>
    );
  }

  const skill = report.skills[0];

  function downloadMd() {
    const md = auditReportToMarkdown(report!);
    const blob = new Blob([md], { type: "text/markdown" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `skillsteroids-audit-${report!.runId}.md`;
    a.click();
    URL.revokeObjectURL(url);
  }

  return (
    <div>
      <p style={{ color: "var(--text-muted)", fontSize: "0.875rem", marginBottom: "1rem" }}>
        Run {report.runId} · Engine {report.engineVersion.slice(0, 7)}
      </p>
      {skill && (
        <>
          <p style={{ marginBottom: "1rem" }}>
            <strong>{skill.skillName}</strong> — <VerdictBadge verdict={skill.verdict} />
          </p>
          <table style={{ width: "100%", borderCollapse: "collapse", fontSize: "0.875rem", marginBottom: "2rem" }}>
            <thead>
              <tr style={{ borderBottom: "1px solid var(--border)", textAlign: "left" }}>
                <th style={{ padding: "0.5rem" }}>Principle</th>
                <th style={{ padding: "0.5rem" }}>Result</th>
                <th style={{ padding: "0.5rem" }}>Detail</th>
              </tr>
            </thead>
            <tbody>
              {[...skill.structural, ...skill.semantic].map((r) => (
                <tr key={r.principle} style={{ borderBottom: "1px solid var(--border)" }}>
                  <td style={{ padding: "0.5rem", fontFamily: "var(--font-mono)" }}>{r.principle}</td>
                  <td style={{ padding: "0.5rem" }}>{r.pass ? "PASS" : "BLOCK"}</td>
                  <td style={{ padding: "0.5rem", color: "var(--text-muted)" }}>{r.message ?? ""}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </>
      )}
      <div style={{ display: "flex", gap: "1rem", flexWrap: "wrap" }}>
        <button type="button" className="btn btn-primary" onClick={downloadMd}>Download report</button>
        <Link href="/studio" className="btn btn-ghost">Audit another</Link>
      </div>
      <p style={{ color: "var(--text-muted)", fontSize: "0.8125rem", marginTop: "2rem" }}>
        Save runs and AI mutation — Pro (Phase 3). Join early access from pricing.
      </p>
    </div>
  );
}
