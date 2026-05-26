---
description: Create or refresh the implementation plan from .agents/tasks/task.md.
---

Read `.agents/tasks/task.md` and ask the `@plan` subagent to create or refresh `.agents/tasks/plan.md` using the `planning` skill. Treat `.agents/tasks/task.md` as the source of truth. Ask clarifying questions only if missing information would block a correct plan. Return a compact summary with:
- plan title
- number of sub-tasks
- any blocking open questions
- recommended next command
