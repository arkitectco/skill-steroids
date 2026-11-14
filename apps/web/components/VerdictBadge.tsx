import type { Verdict } from "@/lib/audit/types";

const cls: Record<Verdict, string> = {
  PASS: "verdict-pass",
  WARN: "verdict-warn",
  BLOCK: "verdict-block",
};

export function VerdictBadge({ verdict }: { verdict: Verdict }) {
  return <span className={cls[verdict]} style={{ fontFamily: "var(--font-mono)", fontWeight: 600 }}>{verdict}</span>;
}
