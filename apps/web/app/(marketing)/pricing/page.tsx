import Link from "next/link";
import { SiteHeader } from "@/components/SiteHeader";
import { SectionLabel } from "@/components/SectionLabel";

export default function PricingPage() {
  return (
    <>
      <SiteHeader />
      <main className="container" style={{ padding: "4rem 1.5rem" }}>
        <SectionLabel>§ Pricing</SectionLabel>
        <h1 className="section-title">Free audit. Pro gains.</h1>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(16rem, 1fr))", gap: "1.5rem", marginTop: "2rem" }}>
          <div style={{ border: "1px solid var(--border)", borderRadius: "0.75rem", padding: "1.5rem" }}>
            <h2 style={{ marginBottom: "0.5rem" }}>Free</h2>
            <p style={{ color: "var(--text-muted)", fontSize: "0.875rem", marginBottom: "1rem" }}>Deterministic audit</p>
            <ul style={{ color: "var(--text-muted)", fontSize: "0.875rem", paddingLeft: "1.25rem" }}>
              <li>Single-skill zip upload</li>
              <li>Structural + semantic checks</li>
              <li>MD report download</li>
            </ul>
            <Link href="/studio" className="btn btn-primary" style={{ marginTop: "1.5rem", display: "inline-flex" }}>Audit now</Link>
          </div>
          <div style={{ border: "1px solid var(--accent-dim)", borderRadius: "0.75rem", padding: "1.5rem" }}>
            <h2 style={{ marginBottom: "0.5rem" }}>Pro</h2>
            <p style={{ color: "var(--accent)", fontSize: "0.875rem", marginBottom: "1rem" }}>Early access — coming Phase 3</p>
            <ul style={{ color: "var(--text-muted)", fontSize: "0.875rem", paddingLeft: "1.25rem" }}>
              <li>AI mutation + diff export</li>
              <li>Saved runs</li>
              <li>Multi-skill library scan</li>
              <li>Mutation quota + BYOK</li>
            </ul>
          </div>
        </div>
      </main>
    </>
  );
}
