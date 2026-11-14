import { SiteHeader } from "@/components/SiteHeader";
import { SectionLabel } from "@/components/SectionLabel";
import { SkillDropzone } from "@/components/SkillDropzone";

export default function StudioPage() {
  return (
    <>
      <SiteHeader />
      <main className="container" style={{ padding: "4rem 1.5rem" }}>
        <SectionLabel>§ Studio</SectionLabel>
        <h1 className="section-title">Audit a skill</h1>
        <p style={{ color: "var(--text-muted)", marginBottom: "2rem" }}>
          Upload a zip of one skill folder. No account required.
        </p>
        <SkillDropzone />
      </main>
    </>
  );
}
