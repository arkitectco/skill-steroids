import Link from "next/link";

export function SiteHeader() {
  return (
    <header style={{ borderBottom: "1px solid var(--border)", padding: "1rem 0" }}>
      <div className="container" style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <Link href="/" style={{ fontFamily: "var(--font-display)", fontSize: "1.25rem", color: "var(--text)" }}>
          SkillSteroids
        </Link>
        <nav style={{ display: "flex", gap: "1.25rem", alignItems: "center", fontSize: "0.875rem" }}>
          <Link href="/#ecosystem">Ecosystem</Link>
          <Link href="/pricing">Pricing</Link>
          <Link href="/studio">Studio</Link>
          <a href="https://github.com/arkitectco/SkillSteroids" target="_blank" rel="noopener">GitHub ↗</a>
        </nav>
      </div>
    </header>
  );
}
