# Publishing SkillSteroids

Release checklist for publishing SkillSteroids to Cursor, Claude, and Codex plugin marketplaces.

## Prerequisites

- Fork `openai-codex-plugins` (for Codex registry submissions)
- GitHub CLI authenticated: `gh auth login`
- Cursor marketplace access (Cursor team account or personal publisher)
- Claude marketplace access (Anthropic org or personal publisher account)

## 1. Version bump

```bash
./scripts/bump-plugin-version.sh 2.2.0
```

This updates version across all declared files: `.cursor-plugin/plugin.json`, `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `.claude-plugin/marketplace.json`, and `packages/skill-pack/package.json`.

## 2. Verify manifests and health

```bash
./scripts/verify-plugin-manifests.sh
./packages/skill-pack/scripts/doctor.sh
./evals/run-eval.sh
./tests/hooks/test-session-start.sh
```

All checks must pass before proceeding.

Hooks ship inside `packages/skill-pack/` and sync to Codex automatically.

## 3. Cursor marketplace

Update the Cursor plugin listing:

1. Open Cursor → Extensions → Manage Publishers
2. Select **skill-steroids** and click **Publish**
3. Or use the Cursor CLI (see [Cursor plugin docs](https://docs.cursor.com/plugins/publishing))

For local plugin install during development:

```bash
# In Cursor: File → Open Local Plugin → select .cursor-plugin/
```

## 4. Claude marketplace

```bash
claude plugin marketplace add ./.claude-plugin/marketplace.json
```

For org-level publish, use the org equivalent command. See [Claude plugin docs](https://docs.anthropic.com/plugins) for details.

## 5. Codex plugin registry

```bash
./scripts/sync-to-codex-plugin.sh -y
```

This syncs the `.codex-plugin/` manifest and skill pack to the Codex plugin registry. Users can then install via:

```bash
# After registry publish:
codex plugin install skill-steroids

# Or symlink directly (OSS fallback):
./install.sh --with-codex
```

## 6. Post-release

1. Update `CHANGELOG.md` with the new version entry
2. Tag the release: `git tag v2.2.0 && git push origin v2.2.0`
3. Create a GitHub release: `gh release create v2.2.0 --generate-notes`
4. Announce in the relevant community channels

## Environment variables

| Variable | Purpose |
|----------|---------|
| `CODEX_HOME` | Override Codex home directory (default: `~/.codex`) |
| `SKILL_STEROIDS_HOME` | Override source directory for symlink installs |
| `SKILL_STEROIDS_CURSOR` | Override Cursor install target |
| `SKILL_STEROIDS_AGENTS` | Set `1` to also install to `~/.agents/skills/` |
