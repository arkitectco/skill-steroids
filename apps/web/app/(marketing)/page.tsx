import Link from "next/link";
import { SiteHeader } from "@/components/SiteHeader";
import { SectionLabel } from "@/components/SectionLabel";
import { TerminalBlock } from "@/components/TerminalBlock";

export default function HomePage() {
  return (
    <>
      <SiteHeader />
      <main>
        <section className="container" style={{ padding: "5rem 1.5rem 4rem" }}>
          <div style={{ display: "flex", gap: "0.5rem", marginBottom: "1.5rem", flexWrap: "wrap" }}>
            <span className="badge">v2.0 · audit free</span>
            <span className="badge">MIT · markdown-first</span>
          </div>
          <h1 className="section-title" style={{ fontSize: "clamp(2.5rem, 5vw, 4.5rem)", maxWidth: "48rem" }}>
            Stack your agent skills.
          </h1>
          <p style={{ fontFamily: "var(--font-mono)", color: "var(--accent)", marginBottom: "1rem" }}>
            [thesis] why skill debt when skill can compound.
          </p>
          <p style={{ color: "var(--text-muted)", maxWidth: "38rem", marginBottom: "2rem", fontSize: "1.0625rem" }}>
            SkillSteroids audits, governs, and evolves your AI skill library — deterministic checks free,
            governed mutation on Pro.
          </p>
          <div style={{ display: "flex", gap: "1rem", flexWrap: "wrap" }}>
            <Link href="/studio" className="btn btn-primary">Audit a skill</Link>
            <Link href="/pricing" className="btn btn-ghost">View pricing →</Link>
          </div>
        </section>

        <section id="ecosystem" className="container" style={{ padding: "4rem 1.5rem" }}>
          <SectionLabel>§ 01 · Ecosystem</SectionLabel>
          <h2 className="section-title">Six skills. One audit pipeline.</h2>
          <p style={{ color: "var(--text-muted)", maxWidth: "40rem", marginBottom: "2rem" }}>
            Observer → Analyzer → Governor → Evolver → Orchestrator → Lineage. Composable OSS modules;
            the studio runs the same govern engine as CI.
          </p>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(16rem, 1fr))", gap: "1rem" }}>
            {["Observer", "Analyzer", "Governor", "Evolver", "Orchestrator", "Lineage"].map((name) => (
              <div key={name} style={{ border: "1px solid var(--border)", borderRadius: "0.5rem", padding: "1.25rem", background: "var(--bg-elevated)" }}>
                <strong>{name}</strong>
              </div>
            ))}
          </div>
        </section>

        <section className="container" style={{ padding: "4rem 1.5rem" }}>
          <SectionLabel>§ 02 · Studio</SectionLabel>
          <h2 className="section-title">Upload. Verdict. Download.</h2>
          <TerminalBlock title="skillsteroids · audit">
{`$ skill steroids audit
▸ extract zip          ✓ SKILL.md found
▸ govern-check.sh        PASS P-02 · PASS P-03 · PASS P-05
▸ govern-semantic.sh     PASS P-01 · PASS P-04 · PASS P-06
→ verdict PASS · download report.md`}
          </TerminalBlock>
        </section>

        <section className="container" style={{ padding: "4rem 1.5rem 6rem" }}>
          <SectionLabel>§ 03 · Proof</SectionLabel>
          <h2 className="section-title">Same engine as OSS evals.</h2>
          <p style={{ color: "var(--text-muted)", marginBottom: "1.5rem" }}>
            Golden fixtures in CI. Web audits must match bash govern-check output.
          </p>
          <Link href="https://github.com/arkitectco/SkillSteroids" className="btn btn-ghost">View on GitHub ↗</Link>
        </section>
      </main>
    </>
  );
}
