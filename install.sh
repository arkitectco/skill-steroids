#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$REPO_ROOT/packages/skill-pack"
if [[ ! -f "$PACK_DIR/SKILL.md" ]]; then
  echo "ERROR: packages/skill-pack not found. Run from SkillSteroids repo root." >&2
  exit 1
fi
CURSOR_TARGET="${SKILL_STEROIDS_CURSOR:-$HOME/.cursor/skills/skill-steroids}"
AGENTS_TARGET="$HOME/.agents/skills/skill-steroids"
CLAUDE_TARGET="$HOME/.claude/skills/skill-steroids"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CODEX_TARGET="$CODEX_HOME/skills/skill-steroids"
SOURCE="${SKILL_STEROIDS_HOME:-$PACK_DIR}"

usage() {
  cat <<EOF
Usage: ./install.sh [--uninstall] [--with-claude] [--with-codex]

  Installs SkillSteroids skill pack via symlink.
  Set SKILL_STEROIDS_AGENTS=1 to also install to ~/.agents/skills/

  --with-claude   Also symlink to ~/.claude/skills/skill-steroids
  --with-codex    Also symlink to \$CODEX_HOME/skills/skill-steroids (default: ~/.codex)
EOF
}

link_dir() {
  local target="$1"
  mkdir -p "$(dirname "$target")"
  if [[ -L "$target" ]]; then
    rm "$target"
  fi
  if [[ -e "$target" && ! -L "$target" ]]; then
    echo "ERROR: $target exists and is not a symlink. Remove manually." >&2
    exit 1
  fi
  ln -sfn "$SOURCE" "$target"
  echo "✓ linked $target -> $SOURCE"
}

unlink_dir() {
  local target="$1"
  if [[ -L "$target" ]]; then
    rm "$target"
    echo "✓ removed $target"
  fi
}

UNINSTALL=0
WITH_CLAUDE=0
WITH_CODEX=0
for arg in "$@"; do
  case "$arg" in
    --uninstall) UNINSTALL=1 ;;
    --with-claude) WITH_CLAUDE=1 ;;
    --with-codex) WITH_CODEX=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown flag: $arg" >&2; usage; exit 1 ;;
  esac
done

if [[ "$UNINSTALL" -eq 1 ]]; then
  unlink_dir "$CURSOR_TARGET"
  unlink_dir "$AGENTS_TARGET"
  unlink_dir "$CLAUDE_TARGET"
  unlink_dir "$CODEX_TARGET"
  exit 0
fi

link_dir "$CURSOR_TARGET"
if [[ "${SKILL_STEROIDS_AGENTS:-0}" == "1" ]]; then
  link_dir "$AGENTS_TARGET"
fi
if [[ "$WITH_CLAUDE" -eq 1 ]]; then
  link_dir "$CLAUDE_TARGET"
fi
if [[ "$WITH_CODEX" -eq 1 ]]; then
  link_dir "$CODEX_TARGET"
fi

if [[ -x "$SOURCE/scripts/doctor.sh" ]]; then
  "$SOURCE/scripts/doctor.sh" || true
fi

echo ""
echo "Done. In Cursor, try: run skill steroids"
