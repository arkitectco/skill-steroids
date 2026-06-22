import path from "path";

/** Monorepo root (evals/, apps/, packages/) */
export function getRepoRoot(): string {
  const fromEnv = process.env.SKILLSTEROIDS_REPO_ROOT;
  if (fromEnv) return fromEnv;
  return path.join(process.cwd(), "../..");
}

/** OSS skill pack (governor, scripts, references) */
export function getPackRoot(): string {
  const fromEnv = process.env.SKILLSTEROIDS_PACK_ROOT;
  if (fromEnv) return fromEnv;
  return path.join(getRepoRoot(), "packages/skill-pack");
}
