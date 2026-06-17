import type { NextConfig } from "next";
import path from "path";

const repoRoot = path.join(__dirname, "../..");

const nextConfig: NextConfig = {
  experimental: {
    serverActions: { bodySizeLimit: "512kb" },
  },
  env: {
    SKILLSTEROIDS_REPO_ROOT: repoRoot,
  },
};

export default nextConfig;
