---
description: Show current task artifact status and recommend the next action
---

Read `.agent-task`, resolve the artifact directory as
`$HOME/agent-vault/<contents-of-.agent-task>`, then read the relevant sections
of `task.md`, optional `research.md`, `plan.md`, and `review.md`.

Report a concise task dashboard:

- resolved artifact path
- task title and status
- research status and recommended approach, if present
- current phase and active subtask
- completed, in-progress, blocked, review, and pending sub-task counts
- unresolved review findings by severity
- latest validation result
- blockers or conflicts between artifacts
- recommended next command/action

Do not scan the rest of `$HOME/agent-vault` unless explicitly asked. Do not
modify files.
