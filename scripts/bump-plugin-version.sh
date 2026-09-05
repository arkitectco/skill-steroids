#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG="$REPO_ROOT/.version-bump.json"

read_json_field() {
  local file="$1" field="$2"
  local jq_path
  jq_path=$(echo "$field" | sed -E 's/\.([0-9]+)/[\1]/g' | sed 's/^/./')
  jq -r "$jq_path" "$file"
}

write_json_field() {
  local file="$1" field="$2" value="$3"
  local jq_path
  jq_path=$(echo "$field" | sed -E 's/\.([0-9]+)/[\1]/g' | sed 's/^/./')
  local tmp="${file}.tmp"
  jq "$jq_path = \"$value\"" "$file" > "$tmp" && mv "$tmp" "$file"
}

read_yaml_frontmatter_version() {
  local file="$1"
  awk '
    BEGIN { fm=0 }
    NR==1 && $0=="---" { fm=1; next }
    fm && $0=="---" { exit }
    fm && /^version:/ {
      sub(/^version:[[:space:]]*/, "")
      gsub(/["'\'']/, "")
      print
      exit
    }
  ' "$file"
}

write_yaml_frontmatter_version() {
  local file="$1" value="$2"
  local tmp="${file}.tmp"
  awk -v ver="$value" '
    BEGIN { fm=0; done=0 }
    NR==1 && $0=="---" { fm=1; print; next }
    fm && !done && /^version:/ { print "version: " ver; done=1; next }
    fm && $0=="---" { fm=0 }
    { print }
  ' "$file" > "$tmp" && mv "$tmp" "$file"
}

cmd_check() {
  local has_drift=0
  local expected_ver=""
  echo "Version check:"

  while IFS=$'\t' read -r path field; do
    local fullpath="$REPO_ROOT/$path"
    if [[ ! -f "$fullpath" ]]; then
      echo "  MISSING: $path ($field)"
      has_drift=1
      continue
    fi
    local got
    got="$(read_json_field "$fullpath" "$field")"
    echo "  $path ($field): $got"
    if [[ -z "$expected_ver" ]]; then
      expected_ver="$got"
    elif [[ "$got" != "$expected_ver" ]]; then
      echo "  ✗ version drift: $path is '$got' (want '$expected_ver')"
      has_drift=1
    fi
  done < <(jq -r '.files[] | "\(.path)\t\(.field)"' "$CONFIG")

  while IFS=$'\t' read -r path field; do
    local fullpath="$REPO_ROOT/$path"
    if [[ ! -f "$fullpath" ]]; then
      echo "  MISSING: $path ($field)"
      has_drift=1
      continue
    fi
    local got
    got="$(read_yaml_frontmatter_version "$fullpath")"
    echo "  $path (frontmatter $field): $got"
    if [[ -z "$expected_ver" ]]; then
      expected_ver="$got"
    elif [[ "$got" != "$expected_ver" ]]; then
      echo "  ✗ version drift: $path is '$got' (want '$expected_ver')"
      has_drift=1
    fi
  done < <(jq -r '.yamlVersion[]? | "\(.path)\t\(.field)"' "$CONFIG")

  local pkg_path pkg_policy
  pkg_path="$(jq -r '.packageJson.path // empty' "$CONFIG")"
  pkg_policy="$(jq -r '.packageJson.policy // empty' "$CONFIG")"
  if [[ "$pkg_policy" == "exclude" && -n "$pkg_path" ]]; then
    echo "ℹ $pkg_path: policy=exclude ($(jq -r '.packageJson.reason' "$CONFIG"))"
    echo "  npm version: $(read_json_field "$REPO_ROOT/$pkg_path" "version") (not required to match $expected_ver)"
  elif [[ "$pkg_policy" == "bump" && -n "$pkg_path" ]]; then
    local pkg_ver
    pkg_ver="$(read_json_field "$REPO_ROOT/$pkg_path" "version")"
    echo "  $pkg_path (version): $pkg_ver"
    if [[ "$pkg_ver" != "$expected_ver" ]]; then
      echo "  ✗ version drift: $pkg_path is '$pkg_ver' (want '$expected_ver')"
      has_drift=1
    fi
  fi

  local nested_policy
  nested_policy="$(jq -r '.nestedSkillVersions.policy // empty' "$CONFIG")"
  if [[ "$nested_policy" == "exclude" ]]; then
    echo "ℹ nested component SKILL.md versions: policy=exclude"
  fi

  echo "Description check:"
  while IFS=$'\t' read -r path field variant; do
    local fullpath="$REPO_ROOT/$path"
    local want got
    want="$(jq -r --arg v "$variant" '.descriptionVariants[$v] // empty' "$CONFIG")"
    if [[ -z "$want" ]]; then
      echo "  ✗ unknown description variant '$variant' for $path"
      has_drift=1
      continue
    fi
    if [[ ! -f "$fullpath" ]]; then
      echo "  MISSING: $path ($field)"
      has_drift=1
      continue
    fi
    got="$(read_json_field "$fullpath" "$field")"
    if [[ "$got" != "$want" ]]; then
      echo "  ✗ $path ($field) variant=$variant"
      echo "    got:  $got"
      echo "    want: $want"
      has_drift=1
    else
      echo "  ✓ $path ($field) = $variant"
    fi
  done < <(jq -r '.descriptions[]? | "\(.path)\t\(.field)\t\(.variant)"' "$CONFIG")

  echo "Command count check:"
  local cmd_dir
  cmd_dir="$REPO_ROOT/$(jq -r '.commands.dir' "$CONFIG")"
  local expected_list got_list
  expected_list="$(jq -r '.commands.expected[]' "$CONFIG" | sort)"
  if [[ ! -d "$cmd_dir" ]]; then
    echo "  ✗ commands dir missing: $cmd_dir"
    has_drift=1
  else
    got_list="$(find "$cmd_dir" -maxdepth 1 -name '*.md' -exec basename {} .md \; | sort)"
    if [[ "$got_list" != "$expected_list" ]]; then
      echo "  ✗ command set drift"
      echo "    got:"
      echo "$got_list" | sed 's/^/      /'
      echo "    want:"
      echo "$expected_list" | sed 's/^/      /'
      has_drift=1
    else
      echo "  ✓ $(echo "$expected_list" | wc -l | tr -d ' ') commands: $(echo "$expected_list" | paste -sd ', ' -)"
    fi
  fi

  local slash_path slash_pattern
  slash_path="$(jq -r '.skillSlashPolicy.path // empty' "$CONFIG")"
  slash_pattern="$(jq -r '.skillSlashPolicy.forbidPattern // empty' "$CONFIG")"
  if [[ -n "$slash_path" && -n "$slash_pattern" ]]; then
    if grep -E "$slash_pattern" "$REPO_ROOT/$slash_path" >/dev/null; then
      echo "✗ $slash_path contains a host slash-command (keep /skill-steroids in plugin/commands/ only)"
      has_drift=1
    else
      echo "✓ $slash_path has no /skill-steroids slash-command (path mentions allowed)"
    fi
  fi

  [[ $has_drift -eq 0 ]] || exit 1
}

cmd_bump() {
  local new_ver="$1"
  while IFS=$'\t' read -r path field; do
    write_json_field "$REPO_ROOT/$path" "$field" "$new_ver"
    echo "✓ $path → $new_ver"
  done < <(jq -r '.files[] | "\(.path)\t\(.field)"' "$CONFIG")
  while IFS=$'\t' read -r path field; do
    write_yaml_frontmatter_version "$REPO_ROOT/$path" "$new_ver"
    echo "✓ $path ($field) → $new_ver"
  done < <(jq -r '.yamlVersion[]? | "\(.path)\t\(.field)"' "$CONFIG")
  local pkg_policy
  pkg_policy="$(jq -r '.packageJson.policy // empty' "$CONFIG")"
  if [[ "$pkg_policy" == "exclude" ]]; then
    echo "ℹ skipped $(jq -r '.packageJson.path' "$CONFIG") (policy=exclude)"
  fi
}

case "${1:-}" in
  --check) cmd_check ;;
  "") echo "Usage: bump-plugin-version.sh <version> | --check" >&2; exit 1 ;;
  -*) echo "Unknown flag: $1" >&2; echo "Usage: bump-plugin-version.sh <version> | --check" >&2; exit 1 ;;
  *) cmd_bump "$1" ;;
esac
