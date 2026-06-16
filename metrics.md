# Skill Botox Metrics & Signals

Use these labels in Observer and Analyzer outputs. Numeric scores are optional in v1; qualitative High/Medium/Low is sufficient.

## Friction Signals (Observer)

| Signal ID | Description | Typical evidence |
|-----------|-------------|------------------|
| F-01 | Context re-explanation | User repeats same constraints 2+ times in session |
| F-02 | Skill ignored | Relevant skill exists but agent did not load it |
| F-03 | Workaround path | User manually overrides agent approach repeatedly |
| F-04 | Token waste | Long skill loaded for trivial task |
| F-05 | Trigger miss | User says trigger phrase; wrong skill or none loads |

## Success Signals

| Signal ID | Description |
|-----------|-------------|
| S-01 | Skill invoked on first relevant turn |
| S-02 | Task completed without principle violations |
| S-03 | User accepts proposal without major edits |
| S-04 | Reduced steps vs prior similar session |

## Library Health (Analyzer)

| Metric | Healthy | Watch | Unhealthy |
|--------|---------|-------|-----------|
| Review coverage | >50% skills reviewed in 30d | 25–50% | <25% |
| Redundancy | No overlapping triggers | 1–2 overlaps | 3+ overlaps same domain |
| Gap coverage | Domain has skill | Partial | Repeated manual work, no skill |
| Principle violations | 0 BLOCK in last run | WARN only | Any unresolved BLOCK |

## Improvement Definition

A change is an improvement only if it resolves ≥1 friction/gap signal AND passes Governor with PASS or WARN (not BLOCK).
