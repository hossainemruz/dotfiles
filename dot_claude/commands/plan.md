---
description: Create or refresh the current implementation plan
---

Read `.agent-task`, resolve `$HOME/agent-vault/<contents-of-.agent-task>`, then
read `task.md` and update `plan.md` in the same directory. Treat `task.md` as
the requirements source of truth and preserve the existing `plan.md` structure.

Create an actionable plan with requirements snapshot, scope, risks, PR-sized
groups, commit-sized subtasks, status markers, and validation guidance. Ask
clarifying questions only if missing information blocks a correct plan. Do not
write implementation code.

Return: plan title, number of subtasks, blockers/open questions, and recommended
next command.
