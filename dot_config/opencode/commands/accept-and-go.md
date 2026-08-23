---
description: Accept the current approved Subtask and continue with the next eligible one.
agent: orchestrator
subtask: false
---

This invocation explicitly accepts the one `ready_for_human_review` Subtask for the exact Task key in `$ARGUMENTS` or unambiguous conversation context. Obtain `human` context and apply the canonical acceptance checks; revise or confirm affected pending work before completion. After transitioning it to `completed`, continue through `/next-subtask` semantics only when Devcroft reports that a pending Subtask is eligible. Treat remaining `$ARGUMENTS` as bounded guidance for the new Subtask. Never infer acceptance of the new work.
