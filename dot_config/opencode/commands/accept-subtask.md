---
description: Explicitly accept the current approved Subtask.
agent: orchestrator
subtask: false
---

This invocation is explicit human acceptance of the one logical `ready_for_human_review` Subtask. Require current passing validation, durable automated approval, no blocker, and a matching backend `ready_for_review` Step. Persist its accepted outcome, decisions, deviations, and future impact, then complete it through the temporary bridge. Never start the next Subtask; when replanning is required, report `/plan` instead of allowing continuation.
