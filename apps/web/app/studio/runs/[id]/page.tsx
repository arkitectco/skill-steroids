import { SiteHeader } from "@/components/SiteHeader";
import { SectionLabel } from "@/components/SectionLabel";
import { ReportClient } from "./ReportClient";

export default async function RunReportPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  return (
    <>
      <SiteHeader />
      <main className="container" style={{ padding: "4rem 1.5rem" }}>
        <SectionLabel>§ Report</SectionLabel>
        <h1 className="section-title">Audit results</h1>
        <ReportClient runId={id} />
      </main>
    </>
  );
}
