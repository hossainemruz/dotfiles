---
description: Accept the current approved Subtask and continue with the next eligible one.
agent: orchestrator
subtask: false
---

This invocation explicitly accepts the one logical `ready_for_human_review` Subtask under the canonical acceptance rules. After persisting and completing it, continue through `/next-subtask` semantics only when a pending Subtask is eligible and the accepted outcome does not require replanning. Treat `$ARGUMENTS` as bounded guidance for the new Subtask. Never infer acceptance of the new work.
