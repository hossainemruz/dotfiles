---
description: Implement the next task from the current plan
---

Read `.agent-task`, resolve `$HOME/agent-vault/<contents-of-.agent-task>`, then
read `plan.md`. Select exactly one subtask using this order:

1. continue the single `In Progress` subtask
2. otherwise mark the first `Pending` subtask as `In Progress`
3. if multiple subtasks are `In Progress`, stop and ask which to continue
4. if none remain, report that there is no remaining implementation work

Implement only that subtask. Keep changes scoped. Run the smallest relevant
validation. Review your own diff against the subtask, fix issues you agree with,
rerun validation if needed, update `review.md` with findings/verdict, update
`plan.md` status/checkpoint, then summarize files changed, validation, review
verdict, and next pending subtask.
