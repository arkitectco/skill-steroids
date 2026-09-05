# Skill Authoring (in-pack)

Evolver create path. Do not load skills from outside this pack.

1. Copy `templates/skill-template.md`.
2. One primary job (P-01). Split if the draft covers unrelated domains.
3. Description: one sentence, WHAT + WHEN, ≤150 chars. No synonym-stacked triggers (P-02).
4. Numbered procedure with explicit Inputs and Outputs (P-05 for orchestrator-style skills).
5. Delegate to other *installed* user skills by name and path; do not paste their bodies (P-04).
6. Markdown-first: add a script only when markdown cannot scan, log, or validate (P-08).
7. Run Governor on the draft before showing the user. Write only after explicit approval.
