---
description: Research and plan an exact Task as reviewable Subtasks.
agent: orchestrator
subtask: false
---

Execute the canonical Devcroft planning workflow. Treat `$ARGUMENTS` as the Task key plus optional constraints or emphasis that cannot override persisted requirements. Resolve the exact Task, obtain `planning` context, clarify blocking requirements yourself, gather bounded repository evidence through `@explore`, and dispatch stateless `@planner` with the complete packet. Persist its research through `devcroft_update_task`, then establish or revise the ordered plan through `devcroft_apply_plan`. Do not edit repository source.

Return the Task key, Subtask count and order, Advisor decisions needed, blockers, and the server's next action.
