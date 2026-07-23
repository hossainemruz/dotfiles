---
description: Review caller-scoped or current working-tree changes.
agent: reviewer
subtask: true
---

Perform an ordinary ad hoc review without invoking `taskctl`. When `$ARGUMENTS` is provided, use it as the review scope. Otherwise, review only the current working-tree diff when that scope is unambiguous; if no usable or unambiguous scope exists, ask the user instead of scanning broadly.

Report only actionable, evidence-backed findings using the review skill's format. If there are none, approve directly.
