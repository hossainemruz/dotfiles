---
description: Resume review remediation or apply human-requested Subtask changes.
agent: orchestrator
subtask: false
---

Resume the current Subtask through the canonical remediation loop. Treat `$ARGUMENTS` as explicit human feedback when supplied; otherwise use the current durable blocking findings. Return the Subtask to `in_progress` when necessary, clear automated approval, route concrete local work to `@remediator` and broader or decision-requiring work to `@builder`, validate through `@executor`, and require another standard or expert review. Stop at logical `ready_for_human_review` or `blocked`; never complete the Subtask.
