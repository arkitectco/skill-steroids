import type { NextConfig } from "next";
import path from "path";

const repoRoot = path.join(__dirname, "../..");
const packRoot = path.join(repoRoot, "plugin/skills/skill-steroids");

const nextConfig: NextConfig = {
  experimental: {
    serverActions: { bodySizeLimit: "512kb" },
  },
  env: {
    SKILLSTEROIDS_REPO_ROOT: repoRoot,
    SKILLSTEROIDS_PACK_ROOT: packRoot,
  },
};

export default nextConfig;
