"use client";

import { useCallback, useState } from "react";
import { useRouter } from "next/navigation";
import type { AuditReport } from "@/lib/audit/types";

const STORAGE_PREFIX = "skillsteroids:run:";

export function saveReport(report: AuditReport) {
  sessionStorage.setItem(`${STORAGE_PREFIX}${report.runId}`, JSON.stringify(report));
}

export function loadReport(runId: string): AuditReport | null {
  const raw = sessionStorage.getItem(`${STORAGE_PREFIX}${runId}`);
  return raw ? (JSON.parse(raw) as AuditReport) : null;
}

export function SkillDropzone() {
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const upload = useCallback(async (file: File) => {
    setError(null);
    setLoading(true);
    try {
      const form = new FormData();
      form.append("file", file);
      const res = await fetch("/api/audit", { method: "POST", body: form });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error ?? "Upload failed");
      saveReport(data as AuditReport);
      router.push(`/studio/runs/${data.runId}`);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Upload failed");
    } finally {
      setLoading(false);
    }
  }, [router]);

  return (
    <div
      onDragOver={(e) => e.preventDefault()}
      onDrop={(e) => {
        e.preventDefault();
        const f = e.dataTransfer.files[0];
        if (f) upload(f);
      }}
      style={{
        border: "2px dashed var(--border)",
        borderRadius: "0.75rem",
        padding: "3rem 2rem",
        textAlign: "center",
        background: "var(--bg-elevated)",
      }}
    >
      <p style={{ marginBottom: "1rem", color: "var(--text-muted)" }}>
        Drop your skill folder (.zip) — must include SKILL.md
      </p>
      <label className="btn btn-primary" style={{ cursor: "pointer" }}>
        {loading ? "Auditing…" : "Choose zip file"}
        <input
          type="file"
          accept=".zip,application/zip"
          hidden
          disabled={loading}
          onChange={(e) => {
            const f = e.target.files?.[0];
            if (f) upload(f);
          }}
        />
      </label>
      {error && <p style={{ color: "var(--block)", marginTop: "1rem", fontSize: "0.875rem" }}>{error}</p>}
    </div>
  );
}
