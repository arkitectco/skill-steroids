# Install SkillSteroids

Install the **skill-steroids plugin**. There is no separate OSS skill-pack install.

| Platform | Install |
|----------|---------|
| Cursor | Install **skill-steroids** from the Cursor marketplace, or **File → Open Local Plugin** and select this repo's plugin surface (`plugin/` / `.cursor-plugin/`) |
| Claude Code | `/plugin marketplace add arkitectco/skill-steroids` then install **skill-steroids** (marketplace `source` is `./plugin`) |
| Grok Build | `grok plugin install arkitectco/skill-steroids#plugin --trust` |
| Codex | Install from the Codex plugin registry after publish |

Plugin installs inject `using-skill-steroids` at session start. Agents learn trigger phrases automatically. The full audit/mutate loop runs when you ask.

## Verify (from a clone)

```bash
./plugin/skills/skill-steroids/scripts/doctor.sh
./plugin/skills/skill-steroids/scripts/stats.sh
./evals/run-eval.sh
```

In a new agent chat: **"skill steroids audit"**

## Uninstall

Remove **skill-steroids** from the host's plugin UI (Cursor / Claude / Grok / Codex). Do not look for a repo `install.sh` — it is gone.

## Triggers

Same on every host: **"run skill steroids"**, **"skill steroids audit"**, **"skill steroids mutate"**.
