---
description: Create or refresh the implementation plan from the current task artifact.
---

Resolve the current task artifact directory from `.agent-task` as
`$HOME/agent-vault/<contents-of-.agent-task>`. Read `task.md` from that
directory and ask the `@plan` subagent to create or refresh `plan.md` in the
same directory using the `planning` skill. Preserve the existing plan template
structure. Treat artifact `task.md` as the source of truth. Ask clarifying
questions only if missing information would block a correct plan. Return a
compact summary with:
- plan title
- number of sub-tasks
- any blocking open questions
- recommended next command
