import { NextRequest, NextResponse } from "next/server";
import { runAuditFromZip } from "@/lib/audit/run-audit";
import { rateLimit } from "@/lib/rate-limit";

export const runtime = "nodejs";
export const maxDuration = 60;

function engineVersion(): string {
  return process.env.VERCEL_GIT_COMMIT_SHA ?? "dev";
}

export async function POST(req: NextRequest) {
  const ip = req.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ?? "unknown";
  if (!rateLimit(ip)) {
    return NextResponse.json({ error: "Rate limit exceeded. Try again later." }, { status: 429 });
  }

  const form = await req.formData();
  const file = form.get("file");
  if (!(file instanceof File)) {
    return NextResponse.json({ error: "Missing file field" }, { status: 400 });
  }

  const buffer = Buffer.from(await file.arrayBuffer());
  if (buffer.length === 0) {
    return NextResponse.json({ error: "Empty file" }, { status: 400 });
  }

  try {
    const report = await runAuditFromZip(buffer, engineVersion());
    return NextResponse.json(report);
  } catch (e) {
    const message = e instanceof Error ? e.message : "Audit failed";
    return NextResponse.json({ error: message }, { status: 400 });
  }
}
