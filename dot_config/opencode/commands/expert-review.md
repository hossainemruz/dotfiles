---
description: Perform expert review for the current Subtask or an explicit ad hoc scope.
agent: orchestrator
subtask: false
---

Dispatch `@expert-reviewer`. For the current Task Subtask, require current implementation and validation context, use `mode: workflow`, persist the result yourself, and route blocking findings to `@builder` unless explicitly mechanical. `$ARGUMENTS` may prioritize but never narrow relevant changed code. For an explicit ad hoc scope, use `mode: ad-hoc`, do not invoke taskctl or mutate workflow state, and report findings only. Never infer human acceptance.
