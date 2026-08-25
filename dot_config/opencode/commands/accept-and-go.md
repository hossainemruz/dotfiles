---
description: Accept the current approved Subtask and continue with the next eligible one.
agent: orchestrator
subtask: false
---

This invocation explicitly accepts the one `ready_for_human_review` Subtask for the exact Task key in `$ARGUMENTS` or unambiguous conversation context. Obtain `human` context and apply the canonical acceptance checks. If decisions or deviations require pending work to be revised or confirmed, do not infer replanning authorization from acceptance: report the impact and stop with `/plan` as the required next action. Otherwise transition it to `completed` and continue through `/next-subtask` semantics only when Devcroft reports that a pending Subtask is eligible. Treat remaining `$ARGUMENTS` as bounded guidance for the new Subtask. Never infer acceptance of the new work.
