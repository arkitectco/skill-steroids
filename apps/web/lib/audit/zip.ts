import AdmZip from "adm-zip";
import fs from "fs";
import os from "os";
import path from "path";

export interface ZipOptions {
  maxBytes: number;
  maxSkills: number;
}

export function extractSkillZip(buffer: Buffer, opts: ZipOptions): string {
  if (buffer.length > opts.maxBytes) {
    throw new Error(`Zip exceeds ${opts.maxBytes} bytes`);
  }

  const zip = new AdmZip(buffer);
  const entries = zip.getEntries();
  if (entries.length > 500) throw new Error("Too many files in zip");

  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "skillsteroids-"));

  for (const entry of entries) {
    if (entry.isDirectory) continue;
    const normalized = path.normalize(entry.entryName);
    if (normalized.startsWith("..") || path.isAbsolute(normalized)) {
      fs.rmSync(tmp, { recursive: true, force: true });
      throw new Error("Zip contains path traversal entry");
    }
    const dest = path.join(tmp, normalized);
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.writeFileSync(dest, entry.getData());
  }

  const skills = findSkillMdFiles(tmp);
  if (skills.length === 0) {
    fs.rmSync(tmp, { recursive: true, force: true });
    throw new Error("No SKILL.md found in zip");
  }
  if (skills.length > opts.maxSkills) {
    fs.rmSync(tmp, { recursive: true, force: true });
    throw new Error(`Zip contains ${skills.length} skills; max ${opts.maxSkills}`);
  }

  return tmp;
}

export function findSkillMdFiles(root: string): string[] {
  const results: string[] = [];
  function walk(dir: string) {
    for (const name of fs.readdirSync(dir)) {
      const full = path.join(dir, name);
      const stat = fs.statSync(full);
      if (stat.isDirectory()) walk(full);
      else if (name === "SKILL.md") results.push(full);
    }
  }
  walk(root);
  return results;
}

export function cleanupExtractDir(dir: string) {
  fs.rmSync(dir, { recursive: true, force: true });
}
