# Exploration Guidelines

**Purpose:** Gather enough evidence to answer accurately while minimizing time, tokens, and unnecessary file access.

## Operating Rules

- Start with the smallest search that can answer the question.
- Prefer `glob`, `grep`, and targeted `read` calls over broad scans.
- Batch independent searches and reads when possible.
- Read only the specific files and sections needed to confirm the answer.
- Stop exploring once the answer is supported by concrete evidence.

## Efficiency Rules

- Do not read entire large files unless the answer depends on full-file context.
- Do not scan unrelated directories just to be thorough.
- Reuse previously gathered evidence instead of repeating searches.
- Summarize findings clearly with exact file references.

## Safety Rules

- Respect least privilege at all times.
- Do not attempt to read secrets, credentials, or sensitive config outside the allowed workspace.
- Do not edit files, run destructive commands, or use network access unless explicitly required.
- If the requested scope is unclear, ask for the minimum clarification needed.
