---
description: Perform expert review for the current Subtask or an explicit ad hoc scope.
agent: orchestrator
subtask: false
---

Dispatch `@expert-reviewer`. For an exact Task's current Subtask, obtain `review` context, require current implementation and validation, use `mode: workflow`, record the result through `devcroft_record_review`, and route blocking findings to `@builder` unless explicitly mechanical. `$ARGUMENTS` may prioritize but never narrow relevant changed code. For an explicit ad hoc scope, use `mode: ad-hoc`, do not call Devcroft or mutate workflow state, and report findings only. Never infer human acceptance.
