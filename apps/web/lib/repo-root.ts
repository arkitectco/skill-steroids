import path from "path";

export function getRepoRoot(): string {
  const fromEnv = process.env.SKILLSTEROIDS_REPO_ROOT;
  if (fromEnv) return fromEnv;
  return path.join(process.cwd(), "../..");
}
