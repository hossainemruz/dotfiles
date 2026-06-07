---
description: Research implementation options before planning the current task
---

Read `.agent-task`, resolve `$HOME/agent-vault/<contents-of-.agent-task>`, then
read `task.md` and any existing `research.md`.

If `research.md` is missing, create it from
`$HOME/agent-vault/templates/research-template.md` and resolve template
variables from `task.md` frontmatter when available:

- `{{TASK_ID}}`
- `{{TASK_TITLE}}`
- `{{PROJECT_NAME}}`
- `{{DATE}}`

Use the current date for `{{DATE}}` if unavailable.

Research directly in the current Claude Code session. Do not use subagents. Use
focused file searches and targeted reads to identify relevant components,
existing patterns, similar implementations, constraints, options, risks, open
questions, and the recommended approach.

Write or refresh `research.md`, preserving its structure and user-authored
content. Treat `task.md` as the source of truth for goal, requirements,
acceptance criteria, constraints, and non-goals. Treat `research.md` as
implementation evidence and approach selection only; it must not expand or
override task scope.

Return: research title, options considered, recommended approach,
blockers/open questions, and recommended next command.
