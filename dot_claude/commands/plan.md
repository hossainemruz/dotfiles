---
description: Create or refresh the current implementation plan
---

Read `.agent-task`, resolve `$HOME/agent-vault/<contents-of-.agent-task>`, then
read `task.md` and, when present, `research.md`. Update `plan.md` in the same
directory directly in the current Claude Code session. Treat `task.md` as the
requirements source of truth; treat `research.md` as implementation evidence,
tradeoff analysis, and recommended approach only. Preserve the existing
`plan.md` structure.

Create an actionable plan with requirements snapshot, scope, risks, PR-sized
groups, commit-sized subtasks, status markers, and validation guidance. Ask
clarifying questions only if missing information blocks a correct plan. Do not
write implementation code. If `research.md` is missing and the task has multiple
plausible approaches, architecture risk, or unclear codebase patterns, recommend
running `/research` before planning.

Return: plan title, number of subtasks, research approach used if any,
blockers/open questions, and recommended next command.
