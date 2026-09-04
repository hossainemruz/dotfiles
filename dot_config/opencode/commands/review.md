---
description: Review caller-scoped or current working-tree changes.
agent: general
subtask: false
---

Perform an ordinary review. When `$ARGUMENTS` is provided, use it as the review scope. Otherwise, resolve only the current working-tree diff when that scope is unambiguous; if no usable scope exists, ask the user before dispatch. Send `@reviewer` a complete bounded packet.

Report only actionable, evidence-backed findings using the review skill's format. If there are no blocking findings, report approval and any non-blocking suggestions.
