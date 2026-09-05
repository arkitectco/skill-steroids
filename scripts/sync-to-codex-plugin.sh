#!/usr/bin/env bash
#
# sync-to-codex-plugin.sh
#
# Sync plugin/skills/skill-steroids from this skill-steroids checkout →
# arkitectco/openai-codex-plugins (plugins/skill-steroids/).
#
# Builds a skill-only temp source dir from plugin/skills/skill-steroids/ +
# .codex-plugin/plugin.json (with skills path rewritten to "./"),
# then rsyncs that into the fork, commits, pushes a sync branch,
# and opens a PR.
#
# Deterministic: running twice against the same upstream SHA produces
# PRs with identical diffs.
#
# Usage:
#   ./scripts/sync-to-codex-plugin.sh                    # full run
#   ./scripts/sync-to-codex-plugin.sh -n                 # dry run
#   ./scripts/sync-to-codex-plugin.sh -y                 # skip confirm
#   ./scripts/sync-to-codex-plugin.sh --local PATH       # existing fork checkout
#   ./scripts/sync-to-codex-plugin.sh --base BRANCH      # default: main
#   ./scripts/sync-to-codex-plugin.sh --bootstrap        # create dest dir if missing
#
# Source: plugin/skills/skill-steroids/ (flattened to Codex plugin root).
#
# Bootstrap mode: skips the "plugin must exist on base" requirement and
# creates plugins/skill-steroids/ when absent.
#
# Requires: bash, rsync, git, gh (authenticated), jq, python3.

set -euo pipefail

# =============================================================================
# Config
# =============================================================================

FORK="${SKILL_STEROIDS_CODEX_FORK:-arkitectco/openai-codex-plugins}"
DEFAULT_BASE="main"
DEST_REL="plugins/skill-steroids"

# =============================================================================
# Args
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
UPSTREAM="$(cd "$SCRIPT_DIR/.." && pwd)"
BASE="$DEFAULT_BASE"
DRY_RUN=0
YES=0
LOCAL_CHECKOUT=""
BOOTSTRAP=0

usage() {
  sed -n '/^# Usage:/,/^# Requires:/s/^# \{0,1\}//p' "$0"
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run)  DRY_RUN=1; shift ;;
    -y|--yes)      YES=1; shift ;;
    --local)       LOCAL_CHECKOUT="$2"; shift 2 ;;
    --base)        BASE="$2"; shift 2 ;;
    --bootstrap)   BOOTSTRAP=1; shift ;;
    -h|--help)     usage 0 ;;
    *)             echo "Unknown arg: $1" >&2; usage 2 ;;
  esac
done

# =============================================================================
# Preflight
# =============================================================================

die() { echo "ERROR: $*" >&2; exit 1; }

command -v rsync   >/dev/null || die "rsync not found in PATH"
command -v git     >/dev/null || die "git not found in PATH"
command -v gh      >/dev/null || die "gh not found — install GitHub CLI"
command -v jq      >/dev/null || die "jq not found in PATH"
command -v python3 >/dev/null || die "python3 not found in PATH"

gh auth status >/dev/null 2>&1 || die "gh not authenticated — run 'gh auth login'"

[[ -d "$UPSTREAM/.git" ]] \
  || die "upstream '$UPSTREAM' is not a git checkout"
[[ -f "$UPSTREAM/.codex-plugin/plugin.json" ]] \
  || die "Codex manifest missing at $UPSTREAM/.codex-plugin/plugin.json"
[[ -d "$UPSTREAM/plugin/skills/skill-steroids" ]] \
  || die "skill not found at $UPSTREAM/plugin/skills/skill-steroids"

# Read version from the Codex manifest
UPSTREAM_VERSION="$(python3 -c \
  'import json,sys; print(json.load(open(sys.argv[1]))["version"])' \
  "$UPSTREAM/.codex-plugin/plugin.json")"
[[ -n "$UPSTREAM_VERSION" ]] \
  || die "could not read 'version' from $UPSTREAM/.codex-plugin/plugin.json"

UPSTREAM_BRANCH="$(cd "$UPSTREAM" && git branch --show-current)"
UPSTREAM_SHA="$(cd "$UPSTREAM" && git rev-parse HEAD)"
UPSTREAM_SHORT="$(cd "$UPSTREAM" && git rev-parse --short HEAD)"

confirm() {
  [[ $YES -eq 1 ]] && return 0
  read -rp "$1 [y/N] " ans
  [[ "$ans" == "y" || "$ans" == "Y" ]]
}

if [[ "$UPSTREAM_BRANCH" != "main" ]]; then
  echo "WARNING: upstream is on '$UPSTREAM_BRANCH', not 'main'"
  confirm "Sync from '$UPSTREAM_BRANCH' anyway?" || exit 1
fi

UPSTREAM_STATUS="$(cd "$UPSTREAM" && git status --porcelain)"
if [[ -n "$UPSTREAM_STATUS" ]]; then
  echo "WARNING: upstream has uncommitted changes:"
  echo "$UPSTREAM_STATUS" | sed 's/^/  /'
  echo "Sync will use working-tree state, not HEAD ($UPSTREAM_SHORT)."
  confirm "Continue anyway?" || exit 1
fi

# =============================================================================
# Build pack-only SYNC_SOURCE
# =============================================================================
# Source is built from plugin/skills/skill-steroids/ (not the whole monorepo),
# so no EXCLUDES array is needed — everything in the skill dir is intentional.

CLEANUP_DIR=""
cleanup() {
  [[ -n "$CLEANUP_DIR" ]] && rm -rf "$CLEANUP_DIR"
}
trap cleanup EXIT

prepare_sync_source() {
  [[ -n "$CLEANUP_DIR" ]] || CLEANUP_DIR="$(mktemp -d)"
  SYNC_SOURCE="$CLEANUP_DIR/sync-source"
  rm -rf "$SYNC_SOURCE"
  mkdir -p "$SYNC_SOURCE"

  # Flatten skill dir to Codex plugin root
  rsync -a "$UPSTREAM/plugin/skills/skill-steroids/" "$SYNC_SOURCE/"

  # Copy Codex manifest and rewrite skills path to "./" (pack is at root)
  mkdir -p "$SYNC_SOURCE/.codex-plugin"
  jq '.skills = "./"' "$UPSTREAM/.codex-plugin/plugin.json" \
    > "$SYNC_SOURCE/.codex-plugin/plugin.json"
}

prepare_sync_source

# =============================================================================
# Prepare destination (clone fork fresh, or use --local)
# =============================================================================

SYNC_BRANCH=""
DEST_REPO=""
DEST=""
PREVIEW_REPO=""
PREVIEW_DEST=""

if [[ -n "$LOCAL_CHECKOUT" ]]; then
  DEST_REPO="$(cd "$LOCAL_CHECKOUT" && pwd)"
  [[ -d "$DEST_REPO/.git" ]] \
    || die "--local path '$DEST_REPO' is not a git checkout"
else
  echo "Cloning $FORK..."
  [[ -n "$CLEANUP_DIR" ]] || CLEANUP_DIR="$(mktemp -d)"
  DEST_REPO="$CLEANUP_DIR/openai-codex-plugins"
  gh repo clone "$FORK" "$DEST_REPO" >/dev/null
fi

DEST="$DEST_REPO/$DEST_REL"

TIMESTAMP="$(date -u +%Y%m%d-%H%M%S)"
if [[ $BOOTSTRAP -eq 1 ]]; then
  SYNC_BRANCH="bootstrap/skill-steroids-${UPSTREAM_SHORT}-${TIMESTAMP}"
else
  SYNC_BRANCH="sync/skill-steroids-${UPSTREAM_SHORT}-${TIMESTAMP}"
fi

# =============================================================================
# Preview checkout setup
# =============================================================================

PREVIEW_REPO="$DEST_REPO"
PREVIEW_DEST="$DEST"

prepare_preview_checkout() {
  if [[ -n "$LOCAL_CHECKOUT" ]]; then
    [[ -n "$CLEANUP_DIR" ]] || CLEANUP_DIR="$(mktemp -d)"
    PREVIEW_REPO="$CLEANUP_DIR/preview"
    git clone -q --no-local "$DEST_REPO" "$PREVIEW_REPO"
    PREVIEW_DEST="$PREVIEW_REPO/$DEST_REL"
  fi

  git -C "$PREVIEW_REPO" checkout -q "$BASE" 2>/dev/null \
    || die "base branch '$BASE' doesn't exist in $FORK"

  if [[ $BOOTSTRAP -ne 1 ]]; then
    [[ -d "$PREVIEW_DEST" ]] \
      || die "base branch '$BASE' has no '$DEST_REL/' — use --bootstrap, or pass --base <branch>"
  fi
}

prepare_preview_checkout

# =============================================================================
# Dry run preview (always shown)
# =============================================================================

RSYNC_ARGS=(-av --delete --delete-excluded)

echo ""
echo "Upstream: $UPSTREAM ($UPSTREAM_BRANCH @ $UPSTREAM_SHORT)"
echo "Version:  $UPSTREAM_VERSION"
echo "Fork:     $FORK"
echo "Base:     $BASE"
echo "Branch:   $SYNC_BRANCH"
if [[ $BOOTSTRAP -eq 1 ]]; then
  echo "Mode:     BOOTSTRAP (creating $DEST_REL/ when absent)"
fi
echo ""
echo "=== Preview (rsync --dry-run) ==="
if [[ $BOOTSTRAP -eq 1 ]]; then
  mkdir -p "$PREVIEW_DEST"
fi
rsync "${RSYNC_ARGS[@]}" --dry-run --itemize-changes "$SYNC_SOURCE/" "$PREVIEW_DEST/"
echo "=== End preview ==="
echo ""

if [[ $DRY_RUN -eq 1 ]]; then
  echo "Dry run only. Nothing was changed or pushed."
  exit 0
fi

# =============================================================================
# Apply
# =============================================================================

confirm "Apply changes, push branch, and open PR?" || { echo "Aborted."; exit 1; }

echo ""

prepare_apply_checkout() {
  git -C "$DEST_REPO" checkout -q "$BASE" 2>/dev/null \
    || die "base branch '$BASE' doesn't exist in $FORK"
  if [[ $BOOTSTRAP -ne 1 ]]; then
    [[ -d "$DEST" ]] \
      || die "base branch '$BASE' has no '$DEST_REL/' — use --bootstrap, or pass --base <branch>"
  fi
}

prepare_apply_checkout
cd "$DEST_REPO"
git checkout -q -b "$SYNC_BRANCH"
echo "Syncing upstream content..."
if [[ $BOOTSTRAP -eq 1 ]]; then
  mkdir -p "$DEST"
fi
rsync "${RSYNC_ARGS[@]}" "$SYNC_SOURCE/" "$DEST/"

# Bail early if nothing changed
if [[ -z "$(git status --porcelain "$DEST_REL")" ]]; then
  echo "No changes — embedded plugin was already in sync with upstream $UPSTREAM_SHORT (v$UPSTREAM_VERSION)."
  exit 0
fi

# =============================================================================
# Commit, push, open PR
# =============================================================================

git add "$DEST_REL"

UPSTREAM_REPO_URL="https://github.com/arkitectco/skill-steroids"

if [[ $BOOTSTRAP -eq 1 ]]; then
  COMMIT_TITLE="bootstrap skill-steroids v$UPSTREAM_VERSION from upstream main @ $UPSTREAM_SHORT"
  PR_BODY="Initial bootstrap of the skill-steroids plugin from upstream \`main\` @ \`$UPSTREAM_SHORT\` (v$UPSTREAM_VERSION).

Creates \`$DEST_REL/\` by flattening \`plugin/skills/skill-steroids/\` to the plugin root and copying \`.codex-plugin/plugin.json\` (with \`\"skills\"\` rewritten to \`\"./\"\`).

Run via: \`scripts/sync-to-codex-plugin.sh --bootstrap\`
Upstream commit: $UPSTREAM_REPO_URL/commit/$UPSTREAM_SHA

This is a one-time bootstrap. Subsequent syncs will use the same script without \`--bootstrap\`."
else
  COMMIT_TITLE="sync skill-steroids v$UPSTREAM_VERSION from upstream main @ $UPSTREAM_SHORT"
  PR_BODY="Automated sync from skill-steroids upstream \`main\` @ \`$UPSTREAM_SHORT\` (v$UPSTREAM_VERSION).

Flattens \`plugin/skills/skill-steroids/\` to \`$DEST_REL/\` and copies the Codex manifest with skills path rewritten to \`\"./\"\`.

Run via: \`scripts/sync-to-codex-plugin.sh\`
Upstream commit: $UPSTREAM_REPO_URL/commit/$UPSTREAM_SHA

Running the sync tool again against the same upstream SHA should produce a PR with an identical diff — use that to verify the tool is behaving."
fi

git commit --quiet -m "$COMMIT_TITLE

Automated sync via scripts/sync-to-codex-plugin.sh
Upstream: $UPSTREAM_REPO_URL/commit/$UPSTREAM_SHA
Branch:   $SYNC_BRANCH"

echo "Pushing $SYNC_BRANCH to $FORK..."
git push -u origin "$SYNC_BRANCH" --quiet

echo "Opening PR..."
PR_URL="$(gh pr create \
  --repo "$FORK" \
  --base "$BASE" \
  --head "$SYNC_BRANCH" \
  --title "$COMMIT_TITLE" \
  --body "$PR_BODY")"

PR_NUM="${PR_URL##*/}"
DIFF_URL="https://github.com/$FORK/pull/$PR_NUM/files"

echo ""
echo "PR opened: $PR_URL"
echo "Diff view: $DIFF_URL"
