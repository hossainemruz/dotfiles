---
description: Create or refresh the implementation plan from .work/task.md.
---

Read `.work/task.md` and ask the `@plan` subagent to create or refresh `.work/plan.md` using the `planning` skill. Treat `.work/task.md` as the source of truth. Ask clarifying questions only if missing information would block a correct plan. Return a compact summary with:
- plan title
- number of sub-tasks
- any blocking open questions
- recommended next command
