---
description: Resume review remediation or apply human-requested Subtask changes.
agent: orchestrator
subtask: false
---

Resume an exact Task's current Subtask through the canonical remediation loop. Treat `$ARGUMENTS` as the Task key and explicit human feedback when supplied; otherwise obtain the current durable blocking findings from `review` context. Transition the Subtask to `in_progress` with feedback when necessary, route concrete local work to `@remediator` and broader or decision-requiring work to `@builder`, validate through `@executor`, and require another standard or expert review recorded through Devcroft. Stop at `ready_for_human_review` or `blocked`; never complete the Subtask.
